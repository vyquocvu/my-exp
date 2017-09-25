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
def saveAd(url, doc, site_id, xpaths, parent_category)
begin
@doc = doc
@url = url
@site_id = site_id
@xpaths = xpaths
@parent_category = parent_category
attributes = AdCrawler::Models::Ad.fields.keys.reject!{ | item | item == '_id'
}
hash = {}
attributes.each do |attribute |
    hash[attribute.to_sym] = self.send("get_#{attribute}")
  end
@ad = AdCrawler::Models::Ad.new(hash)
if @ad.name.present ?
  @ad.save!
  Log.info "\tinserted to Post: #{url}"
end
rescue => e
puts e.inspect
puts e.backtrace
ensure
AdCrawler::Models::Link.where(url: url).update_all(is_visited: true)
end
end
private
def get_image
if @site_id == 2
image = []
@xpaths['image'].each do |image_url |
    image_node = @doc.xpath(image_url).to_a
  image_node.each do |img |
    image << check_link_format(img.attribute('src').text.strip.to_s, @xpaths) if img.present ?
  end
end
end
image
end
def get_characteristics(xpaths, description)
value_node = ""
xpaths.each do |xpath |
  case @site_id.to_s
  when "1"
value_node = @doc.xpath(xpath + "[contains(.,'#{description}')]/td[2]") if xpath.present ?
  break
if value_node.present ?
  when "2"
value_node = @doc.xpath(xpath + "[contains(.,'#{description}')]/td/strong") if xpath.present ?
  break
if value_node.present ?
  when "3"
value_node = @doc.xpath(xpath + "[contains(.,'#{description}')]/div[2]") if xpath.present ?
  break
if value_node.present ?
  else
    value_node = @doc.xpath(xpath)
break
if value_node.present ?
  end
end
value = value_node.try(: text).try(: strip).try(: squish)
return value
end
def get_site_id
@site_id
end
def get_url
@url
end
def get_created_at
Time.now
end
def get_updated_at
Time.now
end
def get_province_name
@provinces.where(code: get_province_code).last.display_name
if get_province_code != '00'
end
def get_district_name
@districts.where(code: get_district_code).last.display_name
if get_district_code != '000'
end
def get_ward_name
@wards.where(code: get_ward_code).last.display_name
if get_ward_code != '00000'
end
def get_category_name
@category.where(code: get_category_code).first.name
if get_category_code != '00'
end
def get_sub_category_name
@sub_category.where(code: get_sub_category_code).first.try(: name) if get_sub_category_code != '00'
end
def get_property_code
return '00'
end
def get_area
if @site_id == 1
value_of_area = get_characteristics(@xpaths['area'], "Diện tích ")
elsif @site_id == 2
value_of_area = get_characteristics(@xpaths['area'], "Tổng diện tích sử dụng:")
else
  @xpaths['area'].each do |xpath |
    area_node = @doc.xpath(xpath)
  value_of_area = area_node.try(: text).try(: strip).try(: squish)
end
end
value_of_area = value_of_area.gsub("m²", "").strip
return value_of_area.to_i
end
def get_direction
value_of_direction = get_characteristics(@xpaths['direction'], "Hướng")
end
def get_description
content_node = ""
@xpaths['description'].each do |xpath_content |
    content_node = @doc.dup
  content_node = content_node.xpath(xpath_content)
break
if content_node.present ?
  end# muabannhadat.vn
content_node.search('.row').remove
content_node.search('.detail-address').remove# batdongsan
content_node.search('.pm-title').remove
content_node.search('.kqchitiet').remove
content_node.search('#LeftMainContent__productDetail_panelTag').remove
content_node.search('#LeftMainContent__productDetail_ltVideo').remove
return content_node.text.gsub("Mô tả chi tiết", "").strip.squish
end
def get_contact_name
contact_name_node = ""
if @site_id == 3
contact_name_node = get_characteristics(@xpaths['contact_name'], "Tên liên lạc")
else
  @xpaths['contact_name'].each do |contact_name |
    contact_name_node = @doc.xpath(contact_name)
  contact_name_node = contact_name_node.try(: text).try(: strip).try(: squish)
break
if contact_name_node.present ?
  end
end
contact_name = contact_name_node
if contact_name_node.present ?
  end
def get_contact_company
return ""
end
def get_contact_address
contact_address_node = ""
if @site_id == 3
contact_address_node = get_characteristics(@xpaths['contact_address'], "Địa chỉ")
else
  @xpaths['contact_address'].each do |contact_address |
    contact_address_node = @doc.xpath(contact_address)
  contact_address_node = contact_address_node.try(: text).try(: strip).try(: squish)
break
if contact_address_node.present ?
  end
end
contact_address = contact_address_node.gsub(/ <!--.*/, '') if contact_address_node.present ?
  contact_address = ""
if contact_address.to_s.include ? "JavaScript"
contact_address = ""
if contact_address.to_s.include ? "Thông tin người đăng tin"
return contact_address
end
def get_contact_phone
contact_phone_node = ""
if @site_id == 3
contact_phone_node = get_characteristics(@xpaths['contact_phone'], "Điện thoại")
contact_phone_node = get_characteristics(@xpaths['contact_phone'], "Mobile") if contact_phone_node.nil ?
  else
    @xpaths['contact_phone'].each do |phone |
      contact_phone_node = @doc.xpath(phone)
    contact_phone_node = contact_phone_node.try(: text).try(: strip).try(: squish)
break
if contact_phone_node.present ?
  end
end
contact_phone = contact_phone_node.gsub("Thông tin người đăng tin", "").strip
if contact_phone_node.present ?
  end
def get_room
end
def get_living_room
end
def get_bed_room
value_of_bed_room = get_characteristics(@xpaths['bed_room'], "Số phòng ngủ")
return value_of_bed_room.to_i
end
def get_kitchen
end
def get_dining_room
end
def get_bath_room
value_of_bath_room = get_characteristics(@xpaths['bath_room'], "Số phòng tắm")
value_of_toilet = get_characteristics(@xpaths['bath_room'], "Số toilet")
return value_of_bath_room.to_i + value_of_toilet.to_i
end
def get_floor
value_of_floor = get_characteristics(@xpaths['floor'], "Số tầng")
value_of_floor = get_characteristics(@xpaths['floor'], "Số lầu") if @site_id == 2
return value_of_floor.to_i
end
def get_built_year
end
def get_moving_date
end
def get_owner
value_of_owner = get_characteristics(@xpaths['owner'], "Chính chủ")
return value_of_owner.present ?
  end
def get_construction_permit
value_of_construction_permit = get_characteristics(@xpaths['construction_permit'], "Tình trạng pháp lý")
return value_of_construction_permit.to_s.include ? "Đã có giấy phép xây dựng" || (value_of_construction_permit.to_s.include ? "Giấy tờ hợp lệ")
end
def get_red_license
value_of_red_license = get_characteristics(@xpaths['red_license'], "Tình trạng pháp lý")
return value_of_red_license.to_s.include ? "Sổ đỏ"
end
def get_pink_license
value_of_pink_license = get_characteristics(@xpaths['pink_license'], "Tình trạng pháp lý")
return (value_of_pink_license.to_s.include ? "Sổ hồng") || (value_of_pink_license.to_s.include ? "Sổ hồng")
end
def get_road
value_of_road = get_characteristics(@xpaths['road'], "Đường trước nhà") if (@site_id == 1 || @site_id == 1)
  value_of_road = get_characteristics(@xpaths['road'], "Mặt tiền") if @site_id == 3
value_of_road = value_of_road.gsub("m", "") if value_of_road.present ?
  return value_of_road.to_i
end
def get_car_parking
value_of_car_parking = get_characteristics(@xpaths['car_parking'], "Chỗ để xe hơi") if @site_id == 1
value_of_car_parking = get_characteristics(@xpaths['car_parking'], "Chỗ đậu xe hơi") if @site_id == 2
return value_of_car_parking.present ?
  end
def get_bike_parking
end
def get_elevator
value_of_elevator = get_characteristics(@xpaths['elevator'], "Thang máy")
return value_of_elevator.present ?
  end
def get_fiber_cable
value_of_fiber_cable = get_characteristics(@xpaths['fiber_cable'], "Internet")
return ((value_of_fiber_cable.to_s.include ? "Cáp quang") || (value_of_fiber_cable.to_s.include ? "WLAN") || (value_of_fiber_cable.to_s.include ? "ADSL"))
end
def get_adsl
value_of_adsl = get_characteristics(@xpaths['adsl'], "Internet")
return ((value_of_adsl.to_s.include ? "Cáp quang") || (value_of_adsl.to_s.include ? "WLAN") || (value_of_adsl.to_s.include ? "ADSL"))
end
def get_wifi
value_of_wifi = get_characteristics(@xpaths['wifi'], "Internet")
return value_of_wifi.to_s.include ? "WIFI"
end
def check_value_in_description(arr)
arr.each do |item |
  if downcaseVietnamese(get_description).include ? item.to_s
return true
break
end
end
return false
end
def get_garden
arr = ["sân vườn"]
check_value_in_description(arr)
end
def get_balcony
arr = ["ban công", "sân thượng"]
return true
if check_value_in_description(arr)
value_of_balcony = get_characteristics(@xpaths['balcony'], "Ban công / Sân thượng")
return value_of_balcony.present ?
  end
def get_swiming_pool
arr = ["hồ bơi"]
return true
if check_value_in_description(arr)
value_of_swiming_pool = get_characteristics(@xpaths['swiming_pool'], "Hồ bơi")
return value_of_swiming_pool.present ?
  end
def get_sercurity
arr = ["bảo vệ"]
check_value_in_description(arr)
end
def get_cleaning
end
def get_safe_cabinet
arr = ["két sắt"]
check_value_in_description(arr)
end
def get_office_cabinet
arr = ["tủ"]
check_value_in_description(arr)
end
def get_bed
arr = ["giường", "đầy đủ nội thất", "nội thất đầy đủ", "nội thất full", "full nội thất", "nội thất cao cấp", "nội thất cơ bản"]
check_value_in_description(arr)
end
def get_table
arr = ["bàn ghế", "đầy đủ nội thất", "nội thất đầy đủ", "nội thất full", "full nội thất", "nội thất cao cấp", "nội thất cơ bản"]
check_value_in_description(arr)
end
def get_air_conditioner
arr = ["điều hòa", "máy lạnh", "đầy đủ nội thất", "nội thất đầy đủ", "nội thất full", "full nội thất", "nội thất cao cấp", "nội thất cơ bản"]
return true
if check_value_in_description(arr)
value_of_air_conditioner = @doc.xpath(@xpaths['air_conditioner']).text.strip
return value_of_air_conditioner.include ? "Điều hòa"
end
def get_fridge
arr = ["tủ lạnh", "đầy đủ nội thất", "nội thất đầy đủ", "nội thất full", "full nội thất", "nội thất cao cấp", "nội thất cơ bản"]
return true
if check_value_in_description(arr)
value_of_fridge = @doc.xpath(@xpaths['fridge']).text.strip
return value_of_fridge.include ? "Tủ lạnh"
end
def get_washing_machine
arr = ["máy giặt", "đầy đủ nội thất", "nội thất đầy đủ", "nội thất full", "full nội thất", "nội thất cao cấp", "nội thất cơ bản"]
return true
if check_value_in_description(arr)
value_of_washing_machine = @doc.xpath(@xpaths['washing_machine']).text.strip
return value_of_washing_machine.include ? "Máy giặt"
end
def get_cooking_appliance
arr = ["máy rửa chén", "đầy đủ nội thất", "nội thất đầy đủ", "nội thất full", "full nội thất", "nội thất cao cấp", "nội thất cơ bản"]
return true
if check_value_in_description(arr)
value_of_cooking_appliance = @doc.xpath(@xpaths['cooking_appliance']).text.strip
return value_of_cooking_appliance.include ? "Máy rửa chén"
end
def get_hospital
arr = ["bệnh viện", "hospital", "y tế"]
return true
if check_value_in_description(arr)
value_of_hospital = get_characteristics(@xpaths['hospital'], "Môi trường xung quanh")
return value_of_hospital.to_s.include ? "Bệnh viện"
end
def get_school
arr = ["trường học", "trường đại học"]
return true
if check_value_in_description(arr)
value_of_school = get_characteristics(@xpaths['school'], "Môi trường xung quanh")
return value_of_school.to_s.include ? "Trường học"
end
def get_super_market
arr = ["siêu thị", "bigc", "lotte mart", "coop mart", "co-op mart", "maximart"]
return true
if check_value_in_description(arr)
value_of_super_market = get_characteristics(@xpaths['super_market'], "Môi trường xung quanh")
return value_of_super_market.to_s.include ? "Siêu thị"
end
def get_transport
value_of_transport = get_characteristics(@xpaths['transport'], "Môi trường xung quanh")
return value_of_transport.to_s.include ? "Giao Thông Công Cộng"
end
def get_sea
value_of_sea = get_characteristics(@xpaths['sea'], "Môi trường xung quanh")
return value_of_sea.to_s.include ? "Biển"
end
def get_temple
value_of_temple = get_characteristics(@xpaths['temple'], "Môi trường xung quanh")
return value_of_temple.to_s.include ? "Chùa"
end
def get_church
arr = ["nhà thờ", "nhà thờ"]
return true
if check_value_in_description(arr)
value_of_church = get_characteristics(@xpaths['church'], "Môi trường xung quanh")
return value_of_church.to_s.include ? "Nhà thờ"
end
def get_status
end
def get_name
name_node = @doc.xpath(@xpaths['name'])
name = name_node.text.strip
if name_node.present ?
  end
def check_link_format(link, xpaths)
if (link.include ? "http://") || (link.include ? "www.") || (link.include ? "https://")
link = link
elsif!link.match(/^\//)
link = SITES_CONFIG_XPATH[xpaths['site_name']]['config']['site_prefix'] + "/" + link
else
  link = SITES_CONFIG_XPATH[xpaths['site_name']]['config']['site_prefix'] + link
end
if link.include ? " "
link = URI.escape(link)
end
link
end
def get_images
images = []
if @site_id == 2
@xpaths['images'].each do |image_url |
    image_node = @doc.xpath(image_url).to_a
  image_node.each do |img |
    images << check_link_format(img.attribute('src').text.strip.to_s, @xpaths) if img.present ?
  end
end
else
  image_node = @doc.xpath(@xpaths['images']).to_a
image_node.each do |img |
  images << check_link_format(img.attribute('src').text.strip.to_s, @xpaths) if img.present ?
  end
end
return images
end
def get_price
i = 1
case @site_id.to_s
when "1"
price = get_characteristics(@xpaths['price'], "Giá")
when "2"
price = @doc.xpath(@xpaths['price']).try(: text).try(: squish).split(': ')[1]
else
  price_node = @doc.xpath(@xpaths['price'])
price = price_node.try(: text).try(: strip).try(: squish)
end
price = downcaseVietnamese(price)
area = get_area
transfer_price_to_milion = transfer_price(price, area)
return transfer_price_to_milion
end
def transfer_price(price, area)
if @site_id == 2
number = price.scan(/\d+/) if price.scan(/\d+/).present ?
if number.size == 1
rprice = number[-1].to_i
if price.include ? "triệu"
rprice = number[-1].to_i / 1000. f
if price.include ? "ngàn"
rprice = number[-1].to_i * 1000
if price.include ? "tỷ"
elsif number.size == 2
rprice = number[-2].to_i * 1000 + number[-1].to_i
if price.include ? "tỷ"
rprice = number[-2].to_i + number[-1].to_i / 1000. f
if !price.include ? "tỷ"
end
if price.include ? "/m2"
rprice = price * area
end
return rprice.to_f
else
  price = price.gsub("vnđ", "").gsub("/tháng", "")
price = price.gsub("triệu", "").strip
if price.include ? "triệu"
if price.include ? "tỷ"
price = price.gsub("tỷ", "").strip
price = price.gsub(",", ".")
price = price.to_f * 1000
end
if price.to_s.include ? "/m2"
price = price.gsub("/m2", "")
if price.include ? "nghìn"
price = price.gsub("nghìn", "").strip
price = price.gsub(",", ".")
price = price.to_f / 1000.000
end
price = price * area
end
return price.to_f
end
end
def get_sub_category_code
sub_category = ""
@xpaths['sub_category_id'].each do |cat |
case @site_id.to_s
when "3"
sub_category = get_characteristics(@xpaths['province_code'], "Loại tin rao")
break
if sub_category.present ?
when "2"
category_code = YAML.load(File.read "crawler/tasks/property_vn/diaoconline_category.yml")
category_diaoc = @doc.xpath(@xpaths['category_id']).try(: text).try(: strip).try(: squish)
category_code['diaoc'].each do |key, values |
  puts key + "-----------------------------" + category_diaoc
if key.include ? category_diaoc
sub_category = @sub_category.where(code: values[1]).last.name
break
end
end
else
  category_node = @doc.xpath(cat)
sub_category = category_node.try(: text).try(: strip).try(: squish)
break
if category_node.present ?
end
end
cat_code = get_category_code
map_sub_category_code(cat_code, sub_category)
end
def get_province_code
return @province_code
if @province_code.present ?
place_node = ""
case @site_id.to_s
when "3"
place_node = get_characteristics(@xpaths['province_code'], "Địa chỉ")
else
  @xpaths['province_code'].each do |province |
    place_node = @doc.xpath(province)
  place_node = place_node.try(: text).try(: strip).try(: squish)
break
if place_node.present ?
end
end
place = place_node
if place_node.present ?
place = place[7.. - 1]
if @site_id == 2
@province_code = map_city(place)
end
def get_district_code
return @district_code
if @district_code.present ?
place_node = ""
case @site_id.to_s
when "3"
place_node = get_characteristics(@xpaths['district_code'], "Địa chỉ")
else
  @xpaths['district_code'].each do |dis |
    place_node = @doc.xpath(dis)
  place_node = place_node.try(: text).try(: strip).try(: squish)
break
if place_node.present ?
end
end
place = place_node
if place_node.present ?
place = place[7.. - 1]
if @site_id == 2
city = map_city(place)
@district_code = map_district(place, city)
end
def get_ward_code
return @ward_code
if @ward_code.present ?
place_node = ""
case @site_id.to_s
when "3"
place_node = get_characteristics(@xpaths['ward_code'], "Địa chỉ")
else
  @xpaths['ward_code'].each do |ward |
    place_node = @doc.xpath(ward)
  place_node = place_node.try(: text).try(: strip).try(: squish)
break
if place_node.present ?
end
end
place = place_node
if place_node.present ?
place = place[7.. - 1]
if @site_id == 2
city = map_city(place)
district = map_district(place, city)
@ward_code = map_ward(place, district)
end
def get_address
place_node = @doc.dup
place_node = ''
case @site_id.to_s
when "3"
place_node = get_characteristics(@xpaths['address'], "Địa chỉ")
else
  @xpaths['address'].each do |address |
    place_node = @doc.xpath(address)
  place_node = place_node.try(: text).try(: strip).try(: squish)
break
if place_node.present ?
end
end
place = place_node
if place_node.present ?
place = place[7.. - 1]
if @site_id == 2
end
def get_posted_at
time_post = ''
if @xpaths['posted_at'].present ?
@xpaths['posted_at'].each do |time |
case @site_id.to_s
when "1"
time_post = get_characteristics(@xpaths['posted_at'], 'Ngày đăng')
time_post = time_post.match(/(\d{2}[-:\/]\d{2}[-:\/]\d{4})/)
break
if time_post.present ?
when "3"
time_post = get_characteristics(@xpaths['posted_at'], 'Ngày đăng tin')
time_post = time_post.match(/(\d{2}[-:\/]\d{2}[-:\/]\d{4})/)
break
if time_post.present ?
else
  time_post = AdCrawler::Models::Link.where(url: @url).last.post_date
break
if time_post.present ?
end
end
DateTime.parse(time_post.to_s) if time_post.present ?
end
end# === = MAPPING === =
def map_city(place)
return '00'
if place.to_s.empty ?
place = downcaseVietnamese(place)
arr_place = place.split(/,|-/)
arr_place[-1] = downcaseVietnamese('Hồ Chí Minh') if arr_place[-1].include ? 'tp.hcm'
arr_place[-1] = downcaseVietnamese('Bà Rịa Vũng Tàu') if (downcaseVietnamese(arr_place[-1]).include ? 'vũng tàu') || (downcaseVietnamese(arr_place[-1]).include ? 'bà rịa')
city = '00'
@provinces.each do |p |
  puts arr_place[-1] + '=====' + p.name
if arr_place[-1].present ? && (arr_place[-1].include ? downcaseVietnamese(p.name))
city = p.code
break
end
end
city = '01'
if city == '00' && place.include ? ("hà nội")
return city
end
def map_district(place, city)
return '000'
if place.to_s.empty ?
place = downcaseVietnamese(place)
arr_place = place.split(/,|-/)
current_district = '000'
if city != '00'
districts = @districts.where(province_code: city)
districts.each do |district |
  if (arr_place[-2].strip == "quận 10" || arr_place[-2].strip == "quận 11" || arr_place[-2].strip == "quận 12")
    districts.each do |d |
      if d.
display_name == arr_place[-2].strip.capitalize
current_district = d.code
break
end
end
break
else
  puts arr_place[-2] + '========' + district.name
if arr_place[-2].include ? downcaseVietnamese(district.name)
current_district = district.code
break
end
end
end
end
return current_district
end
def map_ward(place, district)
puts place
return '00000'
if place.to_s.empty ?
place = downcaseVietnamese(place)
arr_place = place.split(/,|-/)
place = place.gsub(arr_place[-1].to_s, "").gsub(arr_place[-2].to_s, "").gsub(",", "")
ward = '00000'
if district != '000'
wards = @wards.where(district_code: district)
wards.each do |w |
  fix_ward = w.name.to_i != 0 && place.scan(/\d+/)[-1].to_i < 10 ? w.name.to_i.to_s : w.name
puts place.scan(/\d+/)[-1]
puts place + '========' + fix_ward
if place.include ? downcaseVietnamese(fix_ward)
if fix_ward.to_i == 0
ward = w.code
else
  ward = w.code
if place.scan(/\d+/)[-1].to_i == fix_ward.to_i
end
break
end
end
end
return ward
end
def get_category_code
return @category_code
if @category_code.present ?
parent_cat = '00'
category = downcaseVietnamese(@parent_category).strip
case @site_id.to_s
when "3"
return @category_code = '06'
if "cho thuê nhà riêng - cho thuê nhà mặt phố - cho thuê nhà trọ, phòng trọ".include ? category
return @category_code = '07'
if "cho thuê căn hộ chung cư".include ? category
return @category_code = '09'
if "cho thuê văn phòng - cho thuê cửa hàng - ki ốt - cho thuê loại bất động sản khác".include ? category
return @category_code = '10'
if "cho thuê kho, nhà xưởng, đất".include ? category
when "2"
category_code = YAML.load(File.read "crawler/tasks/property_vn/diaoconline_category.yml")
category_diaoc = @doc.xpath(@xpaths['category_id']).try(: text).try(: strip).try(: squish)
category_code['diaoc'].each do |key, values |
  if key.
include ? category_diaoc
print values[0]
parent_cat = values[0]
break
end
end
else
  @category.each do |cat |
    if category.include ? downcaseVietnamese(cat.name)
parent_cat = cat.code
break
end
end
end
@category_code = parent_cat
end
def map_sub_category_code(cat_code, sub_category)
return @sub_category_code
if @sub_category_code.present ?
return '00'
if sub_category.empty ?
parent_sub_cat = ''
sub_category = downcaseVietnamese(sub_category)
category = @sub_category.where(category_code: cat_code)
category.each do |sub_cat |
  puts sub_category + " ------------ " + sub_cat.name
if sub_category.include ? downcaseVietnamese(sub_cat.name)
parent_sub_cat = sub_cat.code
break
end
end
if parent_sub_cat == '00' && cat_code != '00'
parent_sub_cat = @sub_category.where(category_code: cat_code).last.code
end
@sub_category_code = parent_sub_cat
end
end
end
