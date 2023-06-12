require 'rails_helper'

feature 'Tax' do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  context 'User' do
    before do
      sign_in(user)
    end

    scenario 'See no taxes in is profile' do
      visit user_path(user, anchor: 'fincance')

      expect(page).to have_content 'No taxes added yet !'
    end

    scenario 'See previously created taxes in is profile' do
      create(:tax, user: user)
      visit user_path(user, locale: :en, anchor: 'fincance')

      within('table#taxes_table') do
        expect(page).to have_xpath(".//tr", count: 2)
      end
    end

    scenario 'Can delete a tax in is profile' do
      create(:tax, user: user)
      visit user_path(user, locale: :en, anchor: 'fincance')

      within('table#taxes_table') do
        click_on 'Delete'
      end

      expect(page).to have_content 'No taxes added yet !'
    end

    scenario 'Can create a tax in is profile' do
      visit user_path(user, locale: :en, anchor: 'fincance')

      click_on 'Add a tax'

      within "#tax_form_collapse" do
        fill_in 'Name', with: 'Tax newly added'
        fill_in 'Rate', with: '12.5'
        fill_in 'Number', with: '13579'
        click_on 'Confirm'
      end

      within('table#taxes_table') do
        expect(page).to have_xpath(".//tr", count: 2)
        expect(page).to have_content 'Tax newly added'
        expect(page).to have_content '12.5'
        expect(page).to have_content '13579'
      end
    end
  end
end
