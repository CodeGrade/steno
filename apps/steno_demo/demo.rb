#!/usr/bin/env ruby

require 'json'
require 'httparty'

resp = HTTParty.post(
  'http://127.0.0.1:4000/api/v1/jobs',
  headers: {
    "Content-Type" => "application/json",
    "Accept" => "application/json",
  },
  body: {
    "job" => {
      "sub_url"  => "http://192.168.1.146:5000/uploads/4",
      "sub_name" => "hello.tar.gz",
      "gra_url"  => "http://192.168.1.146:5000/uploads/3",
      "gra_name" => "grading.tar.gz",
      "timeout"  => 60,
    },
  }.to_json,
)

puts resp.code
puts resp.body.inspect
