# Container class for images associated with different models in the system.
#
# An image consists of two different images, one full size and one thumbnail.
class Image < ActiveRecord::Base

  belongs_to :event
  belongs_to :culture_provider

  validates_presence_of :description,
    :message => "Bildtexten får inte vara tom"

  after_destroy :cleanup

  attr_accessor :type


  # Alias after rename name => description in case name is used anywhere
  def name
    self.description
  end

  # Keep a reference to the original ActiveRecord save method
  alias :save_orig  :save

  # Override the save method. This method resizes an uploaded
  # image and creates the image's thumbnail before saving the
  # ActiveRecord data.
  def save(upload)

    return false unless valid?

    self.filename = Image.gen_fname
    File.open(self.image_path, "wb") { |f| f.write(upload['datafile'].read) }
    
    img = Magick::Image.read(self.image_path).first
    
    if img.nil?
      raise "Could not read the uploaded image."
    end
    
    img.resize_to_fit!(APP_CONFIG[:upload_image][:width], APP_CONFIG[:upload_image][:height])

    self.width = img.columns
    self.height = img.rows
    
    img.write(self.image_path)

    img.resize_to_fit!(APP_CONFIG[:upload_image][:thumb_width], APP_CONFIG[:upload_image][:thumb_height])

    self.thumb_width = img.columns
    self.thumb_height = img.rows

    img.write(self.thumb_path)
    
    save_orig
  end

  # Generates the name for the thumbnail
  def thumb_name
    Image.thumb_name(self.filename)
  end

  # Generates the filesystem path to the image file
  def image_path
    "#{Image.path}/#{self.filename}"
  end

  # Generates the URL to the image file
  def image_url
    "#{Image.url}/#{self.filename}"
  end

  # Generates the filesystem path to the thumbnail file
  def thumb_path
    "#{Image.path}/#{Image.thumb_name(self.filename)}"
  end

  # Generates the URL to the thumbnail file
  def thumb_url
    "#{Image.url}/#{self.thumb_name}"
  end
  

  # Generates a random filename for the image and thumbnail.
  def self.gen_fname()
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    tempfname = ""

    (1..15).each { |i| tempfname << chars[rand(chars.size-1)] }
    
    while File.exists?("#{Image.path}/#{tempfname}.jpg")
      tempfname << chars[rand(chars.size-1)]
    end
    
    return tempfname.to_s + ".jpg"
  end

  # Creates a thumbnail name for an image
  def self.thumb_name(img)
    regexp = /(\w+?).jpg$/

    if img.is_a? String
      img = Image.new { |i| i.filename = img }
    elsif img.is_a? Integer
      img = Image.find(img)
    else
      return nil
    end
    
    return nil if img.nil?

    img.filename =~ regexp
    return $1 + ".thumb.jpg"
  end

  protected

  # On-destroy callback for deleting the image files.
  def cleanup
    begin
      File.delete image_path
      File.delete thumb_path
    rescue; end
  end

  # Base filesystem path for the image files
  def self.path
    "#{RAILS_ROOT}/public/images/#{APP_CONFIG[:upload_image][:path]}"
  end
  # Base URLs for the image files
  def self.url
    "#{APP_CONFIG[:upload_image][:path]}"
  end

end
