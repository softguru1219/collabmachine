require 'rails_helper'

feature 'Invoice', :vcr do
  let(:user) { create(:user) }
  let!(:user2) { create(:user, last_name: 'Customer', stripe_customer_id: 'cus_DX5f2OMI8tLdxE') }

  before { sign_in(user) }

  scenario 'list invoices I created' do
    create(:profile, provider: 'stripe_connect', user: user)
    create_invoice(user: user, customer: user2)

    visit invoices_path

    within('#created-invoices-list') do
      expect(page).to have_content(user2.full_name)
      expect(page).to have_content('$240')
    end
  end

  scenario 'try to view invoices when the account is not linked to stripe' do
    visit invoices_path

    within('#created-invoices-list') do
      expect(page).to have_content('You have to connect a stripe account to be able to receive payments.')
    end
  end

  scenario 'list invoices I have have to pay' do
    create(:profile, provider: 'stripe_connect', user: user)
    create_invoice(user: user2, customer: user)

    visit invoices_path

    within('#customer-invoices-list') do
      expect(page).to have_content(user2.full_name)
      expect(page).to have_content('$240')
    end
  end

  scenario 'show invoice' do
    invoice = create_invoice(user: user, customer: user2)
    visit invoice_path(invoice)

    expect(page).to have_content(user2.last_name)
    expect(page).to have_content(user.last_name)
    expect(page).to have_content('$200')
  end

  scenario 'create a new invoice' do
    invoicer = create :user
    create(:profile, provider: 'stripe_connect', user: invoicer, uid: "acct_1J2zDlImLCgNPewX")

    invoicee = create :user, email: "testuser@example.com"
    project = create(:project, user: invoicee)
    mission = create(:mission, project: project)
    create(:applicant, mission: mission, user: invoicer, state: "assigned")

    sign_out :user # top-level before block not applicable to this test
    sign_in invoicer

    # Bullet reports unused eager load here, but I can't find or reproduce it in another context
    Bullet.enable = false
    visit new_invoice_path(mission: mission, project: project)
    Bullet.enable = true

    first("#invoice_customer_id option[value='#{invoicee.id}']").select_option
    fill_in 'invoice_invoice_lines_attributes_0_description', with: 'description'
    fill_in 'invoice_invoice_lines_attributes_0_rate', with: '2'
    fill_in 'invoice_invoice_lines_attributes_0_quantity', with: '200'
    click_on 'Send invoice'

    expect(current_path).to eq mission_path(mission)
    expect(page).to have_content('Invoice was successfully created')

    sign_out invoicer
    sign_in invoicee

    visit mission_path(mission)
    within('#finance.tab-pane') do
      expect(page).to have_content('400')
    end
  end

  scenario 'edit an invoice' do
    create(:profile, provider: 'stripe_connect', user: user)
    invoice = create_invoice(user: user, customer: user2)

    visit edit_invoice_path(invoice)
    click_on 'Send invoice'

    expect(current_path).to eq invoices_path
    expect(page).to have_content('Invoice was successfully updated.')
  end

  scenario 'remove an invoice' do
    create(:profile, provider: 'stripe_connect', user: user)
    create_invoice(user: user, customer: user2)
    visit invoices_path

    within('#created-invoices-list tbody tr:first') do
      click_on 'Delete'
    end
  end

  def create_invoice(attributes = {})
    line = build(
      :invoice_line,
      description: 'first line',
      rate: 100,
      quantity: 2
    )

    attributes.reverse_merge!(invoice_lines: [line])
    create(:invoice, attributes)
  end
end
