#encoding: utf-8
class UploadException < RuntimeError; end
#上传文件
class SimpleFileupload
  require 'fileutils'

  def initialize(configs)
    @upload_path = "#{Rails.root}/data"
    @type = @max_size = @random_dir = nil
    configs.each do |key, value|
      if config_keys.include? key
        self.send("#{key}=", value)
      end
    end
    FileUtils.mkdir(@upload_path, mode: 0777) unless File.directory? @upload_path
    FileUtils.chmod(0777, @upload_path) unless File.writable_real?(@upload_path)
    ((0..9).to_a + ('a'..'z').to_a).each &method(:check_and_mkdir) if random_dir?
  end

  def upload(file)
    mime_type = get_mime_type file
    raise UploadException, '文件不是图片格式' if @type == 'image' && !mime_type_is_image?(mime_type)
    file_size = File.size file.tempfile
    file_name = file.original_filename
    raise UploadException, "文件大小超出限制的大小#{@max_size}" if (@max_size && file_size > @max_size.to_i)
    raise UploadException, "上传目录不是目录或不能写入" unless (File.directory?(@upload_path) && File.writable_real?(@upload_path))
    real_file_name = generage_file_name file.original_filename
    random_path = random_dir
    @upload_path = File.join(@upload_path, random_path) if random_path
    file_path = File.join(@upload_path, real_file_name)
    File.open(file_path, 'wb') do |f|
      f.write file.read
    end
  rescue Exception => e
    raise UploadException, '文件上传失败:' + e.message
  else
    {file_name: file_name, real_file_name: real_file_name, file_size: file_size, upload_path: @upload_path, file_full_path: file_path, mime_type: mime_type}
  end

  protected

  def generage_file_name(original_filename)
    if original_filename
      filename = SecureRandom.uuid + File.extname(original_filename)
      if File.exist? File.join(@upload_path, filename)
        generage_file_name(original_filename)
      else
        filename
      end
    end
  end

  def is_image?(file)
    get_mime_type(file) =~ /^image/
  end

  def get_mime_type(file)
    `file --mime -b #{file.tempfile.path}`
  end

  def mime_type_is_image?(mime_type)
    mime_type =~ /^image/
  end

  def config_keys
    [:upload_path, :max_size, :type, :random_dir]
  end

  def upload_path=(path)
    @upload_path = path
  end

  def max_size=(size)
    @max_size = size
  end

  def type=(type)
    @type = type
  end


  def random_dir=(random_dir)
    @random_dir = random_dir
  end

  def random_dir?
    @random_dir
  end

  def check_and_mkdir(dir)
    dir_name = File.join(@upload_path, dir.to_s)
    FileUtils.mkdir(dir_name, mode: 0777) unless File.directory? dir_name
    FileUtils.chmod(0777, dir_name)
  end

  def random_dir
    random_dir? ? ((0..9).to_a + ('a'..'z').to_a).sample : nil
  end
end