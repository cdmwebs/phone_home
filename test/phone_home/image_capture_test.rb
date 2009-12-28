require File.dirname(__FILE__) + '/../test_helper'

class PhoneHome::ImageCaptureTest < Test::Unit::TestCase
  context 'initialization' do
    setup do
      @command ="/usr/sbin/screencapture -x -m -t jpg -T 1"  
      @output_path = File.join(File.dirname(__FILE__), 'images') 
    end

    should "require an image capture command and an output path" do
      assert_raises PhoneHome::ConfigurationError do
        image_capture = PhoneHome::ImageCapture.new
      end
    end

    should "supply image capture and output path as required options in a hash" do
      image_capture = PhoneHome::ImageCapture.new :command     => @command,
                                                  :output_path => @output_path 
      assert_equal @command, image_capture.command
      assert_equal @output_path, image_capture.output_path
    end

    should "be able to supply the image name as an option" do
      image_capture = PhoneHome::ImageCapture.new :command     => @command,
                                                  :output_path => @output_path ,
                                                  :image_name  => 'picture'
      assert_equal 'picture', image_capture.image_name
    end

    should "default the image name to image" do
      image_capture = PhoneHome::ImageCapture.new :command     => @command,
                                                  :output_path => @output_path 
      assert_equal 'image', image_capture.image_name
    end
  end

  context 'capturing an image' do
    setup do
      @command ="/usr/sbin/screencapture -x -m -t jpg -T 1"  
      @output_path = File.join('/tmp/images') 

      @image_capture = PhoneHome::ImageCapture.new :command     => @command,
                                                   :output_path => @output_path,
                                                   :image_name  => 'screen'
    end

    should "write to the output path when asked to capture" do
      precapture_count = count_files_in_folder(@output_path, "*screen*")
      @image_capture.capture
      postcapture_count = count_files_in_folder(@output_path, "*screen*")
      assert_equal precapture_count + 1, postcapture_count
    end
  end

  def count_files_in_folder(folder, file_mask)
    Dir.glob(File.join(folder, file_mask)).size 
  end
end
