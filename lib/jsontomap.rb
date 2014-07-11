require 'geocoder'
require 'json'

class JSONToMap
  def initialize(input, geocodefield, picturefield, namefield)
    @input = JSON.parse(input)
    @geocodefield = geocodefield
    @picturefield = picturefield
    @namefield = namefield
    @geotrack = 0
  end

  # Generates the JSON for the map
  def genmap
    outarray = Array.new
    
    @input.each do |i|
      if i[@geocodefield]
        temphash = Hash.new
        temphash["type"] = "Feature"
        temphash["properties"] = genpopup(i)

        # Geocode and chceck if it succeeded
        if i[@geocodefield].is_a? Array
          i[@geocodefield].each do |g|
            geohash = Hash.new
            geohash["type"] = "Point"
            cleaned = g.strip
            
            # Geocode
            if @geotrack < 10
              geocoded = Geocoder.coordinates(cleaned)
              @geotrack += 1
            else
              sleep(1)
              geocoded = Geocoder.coordinates(cleaned)
              @geotrack = 1
            end

            begin
              geohash["coordinates"] = [geocoded[1], geocoded[0]]
              temphash["geometry"] = geohash
              outarray.push(temphash)
            rescue
            end
          end

        else
          temphash["geometry"] = geocode(i)
          if temphash["geometry"] == "failed"
          else
            outarray.push(temphash)
          end
        end
      end
    end

    return JSON.pretty_generate(outarray)
  end

  # Gets the coordinates for any location
  def geocode(item)
    geohash = Hash.new
    geohash["type"] = "Point"

    if @geotrack < 10
      geocoded = Geocoder.coordinates(item[@geocodefield])
      @geotrack += 1
    else
      sleep(1)
      geocoded = Geocoder.coordinates(item[@geocodefield])
      @geotrack = 1
    end

    begin
      geohash["coordinates"] = [geocoded[1], geocoded[0]]
      return geohash
    rescue
      return "failed"
    end
  end

  # Generates formatted popup text
  def genpopup(item)
    popuphash = Hash.new
    popupstring = ""
    
    if item[@picturefield]
      if (item[@picturefield].include? ".jpg") || (item[@picturefield].include? ".png")
        popupstring = '<img src="'+item[@picturefield]+'" /><br />'
      end
    end
    
    popupstring = popupstring + "<b>" + item[@namefield] + "</b><br /><br />"

    item.each do |k,v|
      popupstring = popupstring + "<b>" + k + "</b>: " + v.to_s + "<br />"
    end
    popuphash["popupContent"] = popupstring
    return popuphash
  end

  # Get coordinates for start location
  def geocodestart(location)
    out = Geocoder.coordinates(location)
    switched = [out[1], out[0]]
    return switched
  end
end
