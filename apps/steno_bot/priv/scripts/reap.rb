#!/usr/bin/env ruby
require 'json'

cs = JSON.parse(`lxc list --format=json`)
cs.each do |cc|
  name = cc["name"]
  next unless name =~ /^steno-/
  system(%Q{lxc stop --force "#{name}"})
end
