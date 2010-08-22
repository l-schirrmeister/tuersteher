require "spec_helper"

module Tuersteher

  describe PathAccessRule do

    before(:all) do
      @rule = PathAccessRule.new '/admin', :get, :sysadmin, :admin
    end


    context "for User with role :admin" do
      before do
        @user = stub('user')
        @user.stub(:has_role?).with(:sysadmin, :admin).and_return(true)
      end

      it "should be fired for path='/admin/xyz' and method :get" do
        @rule.fired?("/admin/xyz", :get, @user).should be_true
      end

      it "should not be fired for other path" do
        @rule.fired?('/todos/admin', :get, @user).should_not be_true
      end

      it "should not be fired for other method as :get" do
        @rule.fired?("/admin/xyz", :post, @user).should_not be_true
      end
    end


    context "for User without role :admin" do
      before do
        @user = stub('user')
        @user.stub(:has_role?).and_return(false)
      end

      it "should not be fired for correct path and method" do
        @rule.fired?("/admin/xyz", :get, @user).should_not be_true
      end
    end


    context "Rule with :all as Path-Matcher" do
      before(:all) do
        @rule = PathAccessRule.new :all, :get, :sysadmin, :admin
        @user = stub('user')
        @user.stub(:has_role?).and_return(true)
      end

      it "should fired for several paths" do
        @rule.fired?("/admin/xyz", :get, @user).should be_true
        @rule.fired?("/xyz", :get, @user).should be_true
        @rule.fired?("/", :get, @user).should be_true
      end

      it "should not be fired with other method" do
        @rule.fired?("/admin/xyz", :post, @user).should_not be_true
      end
    end


    context "Rule with :all as Methode-Matcher" do
      before(:all) do
        @rule = PathAccessRule.new '/admin', :all, :sysadmin, :admin
        @user = stub('user')
        @user.stub(:has_role?).and_return(true)
      end

      it "should fired for several methods" do
        @rule.fired?("/admin/xyz", :get, @user).should be_true
        @rule.fired?("/admin/xyz", :post, @user).should be_true
        @rule.fired?("/admin/xyz", :put, @user).should be_true
        @rule.fired?("/admin/xyz", :delete, @user).should be_true
      end

      it "should not be fired with other path" do
        @rule.fired?("/xyz", :post, @user).should_not be_true
      end
    end


    context "Rule with :all as Role-Matcher" do
      before(:all) do
        @rule = PathAccessRule.new '/admin', :get, :all
        @user = stub('user')
        @user.stub(:has_role?).and_return(false)
      end

      it "should fired for user with no rules" do
        @rule.fired?("/admin/xyz", :get, @user).should be_true
      end

      it "should not be fired with other path" do
        @rule.fired?("/xyz", :get, @user).should_not be_true
      end
    end

  end
end