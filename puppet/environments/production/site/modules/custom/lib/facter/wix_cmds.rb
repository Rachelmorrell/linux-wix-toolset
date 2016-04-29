Facter.add(:wix_cmds) do
    setcode do
      `ls /usr/share/wix/[a-z]*exe`.chomp.split("\n")
    end
end
