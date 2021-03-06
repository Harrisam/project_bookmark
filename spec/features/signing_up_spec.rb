require 'spec_helper'

feature "User signs up" do 

	#Strictly speaking, the test that check the UI
	#(have_content, etc.) should be separate from the tests
	#that check what we have in the DB. The reason is that
	#you should test one thing at a time, whereas
	#by mixing the two we're testing both
	#the business logic and the views.

	#how ever, let's not worry about this yet
	#to keep the example simple.
	
	scenario "when being logged out" do
		lambda { sign_up }.should change(User, :count).by(1)
		expect(page).to have_content("Welcome, alice@example.com")
		expect(User.first.email).to eq("alice@example.com")
	end

	scenario "with a password that doesn't match" do  
		lambda { sign_up('a@a.com', 'pass', 'wrong') }.should change(User, :count).by(0)
		expect(current_path).to eq('/users')
		expect(page).to have_content("Sorry, your passwords don't match")
	end

	scenario "with an email that has already registered" do
		lambda { sign_up }.should change(User, :count).by(1)
		lambda { sign_up }.should_not change(User, :count)
		expect(page).to have_content("Are you sure you have not previously registered?")
	end

	scenario "with an email that is already registered" do 
		lambda { sign_up }.should change(User, :count).by(1)
		lambda { sign_up }.should change(User, :count).by(0)
		expect(page).to have_content("This email is already taken Are you sure you have not previously registered?")
	end

	def sign_up(email = "alice@example.com",
				password = 'oranges!',
				password_confirmation = 'oranges!')
		visit '/users/new'
		fill_in :email, with: email
		fill_in :password, with: password
		fill_in :password_confirmation, with: password_confirmation
		click_button "Sign up"
	end
end

