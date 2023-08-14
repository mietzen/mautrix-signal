title "Maurirx-Signal Host System Test"

describe docker_container('mautrix-signal') do
  it { should exist }
  it { should be_running }
end

describe docker_container('synapse') do
  it { should exist }
  it { should be_running }
end

describe command('docker logs synapse 2>&1 | grep -o "No more background updates to do. Unscheduling background update task"') do
  its('stdout') { should eq "No more background updates to do. Unscheduling background update task\n" }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end

describe command('docker logs mautrix-signal 2>&1 | grep -o "io.finn.signald.Main - Started signald"') do
  its('stdout') { should eq "io.finn.signald.Main - Started signald\n" }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end

describe command('docker logs mautrix-signal 2>&1 | grep -o "Startup actions complete"') do
  its('stdout') { should eq "Startup actions complete\n" }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end

describe command('docker logs mautrix-signal 2>&1 | grep -o "Connected to signald"') do
  its('stdout') { should eq "Connected to signald\n" }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end


