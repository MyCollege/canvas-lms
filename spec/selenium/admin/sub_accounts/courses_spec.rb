require File.expand_path(File.dirname(__FILE__) + '/../../common')

describe "sub account courses" do
  it_should_behave_like "in-process server selenium tests"
    let(:account) { Account.create(:name => 'sub account from default account', :parent_account => Account.default) }
    let(:url) { "/accounts/#{account.id}" }

    before (:each) do
      course_with_admin_logged_in
    end

    it "should add a new course" do
      course_name = 'course 1'
      course_code = '12345'
      get url

      f(".add_course_link").click
      wait_for_ajaximations
      f("#add_course_form #course_name").send_keys(course_name)
      f("#course_course_code").send_keys(course_code)
      submit_form("#add_course_form")
      refresh_page # we need to refresh the page so the course shows up
      course = Course.find_by_name(course_name)
      course.should be_present
      course.course_code.should == course_code
      f("#course_#{course.id}").should be_displayed
      f("#course_#{course.id}").should include_text(course_name)
    end
  end
