require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'thor/actions'

describe Thor::Actions::CreateFile do
  before(:each) do
    ::FileUtils.rm_rf(destination_root)
  end

  def create_file(destination=nil, config={}, options={})
    @base = MyCounter.new([1,2], options, { :destination_root => destination_root })
    stub(@base).file_name { 'rdoc' }

    @action = Thor::Actions::CreateFile.new(@base, destination, "CONFIGURATION",
                                            { :verbose => !@silence }.merge(config))
  end

  def invoke!
    capture(:stdout){ @action.invoke! }
  end

  def revoke!
    capture(:stdout){ @action.revoke! }
  end

  def silence!
    @silence = true
  end

  describe "#invoke!" do
    it "creates a file" do
      create_file("doc/config.rb")
      invoke!
      File.exists?(File.join(destination_root, "doc/config.rb")).must be_true
    end

    it "does not create a file if pretending" do
      create_file("doc/config.rb", {}, :pretend => true)
      invoke!
      File.exists?(File.join(destination_root, "doc/config.rb")).must be_false
    end

    it "shows created status to the user" do
      create_file("doc/config.rb")
      invoke!.must == "      create  doc/config.rb\n"
    end

    it "does not show any information if log status is false" do
      silence!
      create_file("doc/config.rb")
      invoke!.must be_empty
    end

    it "returns the destination" do
      capture(:stdout) do
        create_file("doc/config.rb").invoke!.must == File.join(destination_root, "doc/config.rb")
      end
    end

    it "converts encoded instructions" do
      create_file("doc/%file_name%.rb.tt")
      invoke!
      File.exists?(File.join(destination_root, "doc/rdoc.rb.tt")).must be_true
    end

    describe "when file exists" do
      before(:each) do
        create_file("doc/config.rb")
        invoke!
      end

      describe "and is identical" do
        it "shows identical status" do
          create_file("doc/config.rb")
          invoke!
          invoke!.must == "   identical  doc/config.rb\n"
        end
      end

      describe "and is not identical" do
        before(:each) do
          File.open(File.join(destination_root, 'doc/config.rb'), 'w'){ |f| f.write("FOO = 3") }
        end

        it "shows forced status to the user if force is given" do
          create_file("doc/config.rb", {}, :force => true).must_not be_identical
          invoke!.must == "       force  doc/config.rb\n"
        end

        it "shows skipped status to the user if skip is given" do
          create_file("doc/config.rb", {}, :skip => true).must_not be_identical
          invoke!.must == "        skip  doc/config.rb\n"
        end

        it "shows forced status to the user if force is configured" do
          create_file("doc/config.rb", :force => true).must_not be_identical
          invoke!.must == "       force  doc/config.rb\n"
        end

        it "shows skipped status to the user if skip is configured" do
          create_file("doc/config.rb", :skip => true).must_not be_identical
          invoke!.must == "        skip  doc/config.rb\n"
        end

        it "shows conflict status to ther user" do
          create_file("doc/config.rb").must_not be_identical
          mock($stdin).gets{ 's' }
          file = File.join(destination_root, 'doc/config.rb')

          content = invoke!
          content.must =~ /conflict  doc\/config\.rb/
          content.must =~ /Overwrite #{file}\? \(enter "h" for help\) \[Ynaqdh\]/
          content.must =~ /skip  doc\/config\.rb/
        end

        it "creates the file if the file collision menu returns true" do
          create_file("doc/config.rb")
          mock($stdin).gets{ 'y' }
          invoke!.must =~ /force  doc\/config\.rb/
        end

        it "skips the file if the file collision menu returns false" do
          create_file("doc/config.rb")
          mock($stdin).gets{ 'n' }
          invoke!.must =~ /skip  doc\/config\.rb/
        end

        it "executes the block given to show file content" do
          create_file("doc/config.rb")
          mock($stdin).gets{ 'd' }
          mock($stdin).gets{ 'n' }
          mock(@base.shell).system(/diff -u/)
          invoke!
        end
      end
    end
  end

  describe "#revoke!" do
    it "removes the destination file" do
      create_file("doc/config.rb")
      invoke!
      revoke!
      File.exists?(@action.destination).must be_false
    end

    it "does not raise an error if the file does not exist" do
      create_file("doc/config.rb")
      revoke!
      File.exists?(@action.destination).must be_false
    end
  end

  describe "#exists?" do
    it "returns true if the destination file exists" do
      create_file("doc/config.rb")
      @action.exists?.must be_false
      invoke!
      @action.exists?.must be_true
    end
  end

  describe "#identical?" do
    it "returns true if the destination file and is identical" do
      create_file("doc/config.rb")
      @action.identical?.must be_false
      invoke!
      @action.identical?.must be_true
    end
  end
end
