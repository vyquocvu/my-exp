#!/usr/bin/env ruby

#
encoding: utf - 8
require 'yaml'
require 'mongoid'
require 'unicode'
require 'byebug'
module AdCrawler
class StaticData
def initialize
@provinces = AdCrawler::Models::Province.all
@districts = AdCrawler::Models::District.all
@wards = AdCrawler::Models::Ward.all
@category = AdCrawler::Models::Category.all
@sub_category = AdCrawler::Models::SubCategory.all
@doc = nil
@url = nil
@site_id = nil
@xpaths = nil
@parent_category = nil
end
end
class AdDetailPage < StaticData## Convert Vietnamese to no marks
def remove_accent(source)
unicode = {
  'a' => /á|à|ả|ã|ạ|ă|ắ|ặ|ằ|ẳ|ẵ|â|ấ|ầ|ẩ|ẫ|ậ/,
  'd' => /đ/,
  'e' => /é|è|ẻ|ẽ|ẹ|ê|ế|ề|ể|ễ|ệ/,
  'i' => /í|ì|ỉ|ĩ|ị/,
  'o' => /ó|ò|ỏ|õ|ọ|ô|ố|ồ|ổ|ỗ|ộ|ơ|ớ|ờ|ở|ỡ|ợ/,
  'u' => /ú|ù|ủ|ũ|ụ|ư|ứ|ừ|ử|ữ|ự/,
  'y' => /ý|ỳ|ỷ|ỹ|ỵ/,
  'A' => /Á|À|Ả|Ã|Ạ|Ă|Ắ|Ặ|Ằ|Ẳ|Ẵ|Â|Ấ|Ầ|Ẩ|Ẫ|Ậ/,
  'D' => /Đ/,
  'E' => /É|È|Ẻ|Ẽ|Ẹ|Ê|Ế|Ề|Ể|Ễ|Ệ/,
  'I' => /Í|Ì|Ỉ|Ĩ|Ị/,
  'O' => /Ó|Ò|Ỏ|Õ|Ọ|Ô|Ố|Ồ|Ổ|Ỗ|Ộ|Ơ|Ớ|Ờ|Ở|Ỡ|Ợ/,
  'U' => /Ú|Ù|Ủ|Ũ|Ụ|Ư|Ứ|Ừ|Ử|Ữ|Ự/,
  'Y' => /Ý|Ỳ|Ỷ|Ỹ|Ỵ/,
  "-" => /[^a-zA-Z\d]/
}
unless source.nil ?
  unicode.each do |nonUni, uni |
    source = source.rstrip
  source = source.lstrip
source = source.gsub(/ +/, " ")
source = source.gsub(uni, nonUni)
source = source.gsub(/-+/, "-")
end
source.downcase
end
end## Create mapping province## Convert Vietnamese and keep marks
def downcaseVietnamese(source)
unless source.nil ?
  source = source.rstrip
source = source.lstrip
source = source.gsub(/ +/, " ")
end
return Unicode::downcase(source)
end#--Maps data using master data
def mapData(raw_data, master_data)
type = raw_data
unless raw_data.nil ?
  raw_data = downcaseVietnamese(raw_data)
master_data.each do |data |
  data.mapping.each do |v |
    if raw_data.include ? v
type = data.name
break
end
end
end
end
type
end## Save ad info to db
