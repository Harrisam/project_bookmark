require 'spec_helper'


feature "user forgets password" do

	before(:each) do  
		User.create!(:email => "test@test.com",
					:password => 'test',
					:password_confirmation => 'test',
					:reset_password_token => 'ABCDEF123456',
					:reset_password_token_timestamp => Time.now)
	end

	scenario "sending password request" do  
		visit '/sessions/new'
		expect(page).to_not have_content "Reset password link sent"

		fill_in 'reset_email', with: 'test@test.com'
		click_button 'Forgotten password'

		expect(page).to have_content "Reset password link sent" 
	end


	scenario "resetting a password with a valid link" do  
		visit '/reset_password/ABCDEF123456'

		expect(page).to have_content "Reset Password"
	end

	scenario "trying to reset a password with an invalid link" do  
		visit '/reset_password/invalid'

		expect(page).to have_content "Not found"
	end

	scenario "creating a new password" do  		
		visit '/reset_password/ABCDEF123456'
		fill_in 'password', with: '1234'
		fill_in 'password_confirmation', with: '1234'
		click_button 'Reset Password'
		expect(page).to have_content "Password successfully changed"
	end


end