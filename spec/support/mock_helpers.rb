module MockHelpers
  # reusable mocks

  def mock_google_sheets_blitz_to_collab_api_calls
    sheet_id = "1E9aoKrHcm7_A9Lc6PPoDyJZyJS0cyl4OjyRwGjtGM_k"

    participants_header_row = ["PROCESS", "SYNC", "Prénom", "Nom", "Role", "Secteur principal", "Organisation", "Domaines", "Email", "Téléphone", "Linkedin", "Site web", "Demandes", "Note interne & Disponibilités", "Notes publiques", "SUIVI", "URL avant jitsi", "Salle jitsi", "Nom complet", "Utilisateur::Email", "9h15", "9h50", "10h25", "11h00", "11h35", "MIDI LUNCH", "13h00", "13h35", "14h10", "14h45", "15h20", "15h55"]
    participants_body_row_1 = ["1", "FALSE", "TestUser", "NumberOne", "Entrepreneur", "", "OtonomiPV", "Logiciel d'aide au dimensionnement d'installation photovoltaiques", "testuser1@gmail.com", "", "https://www.linkedin.com/in/asdf1/", "", "entrées d'argent lorsque l'on sera à 100% sur otonomi", "", "", "https://meet.jit.si/blitz-asdf1", "TestUser One", "TestUser One::testuser1@gmail.com", "", "", "", "", "", "x", "", "", "", "TestUser One::testuser1@gmail.com", "TestUser One::testuser1@gmail.com", "TestUser One::testuser1@gmail.com"]
    participants_body_row_2 = ["2", "TRUE", "TestUser", "NumberTwo", "Entrepreneur", "", "OtonomiPV", "Logiciel d'aide au dimensionnement d'installation photovoltaiques", "testuser2@gmail.com", "", "https://www.linkedin.com/in/asdf2/", "", "entrées d'argent lorsque l'on sera à 100% sur otonomi", "", "", "https://meet.jit.si/blitz-asdf2", "TestUser Two", "TestUser Two::testuser2@gmail.com", "", "", "", "", "", "x", "", "", "", "TestUser Two::testuser2@gmail.com", "TestUser Two::testuser2@gmail.com", "TestUser Two::testuser2@gmail.com"]

    coaches_header_row = ["PROCESS", "SYNC", "Prénom", "Nom", "Role", "Secteur principal", "Organisation", "Domaines", "Email", "Téléphone", "Linkedin", "Site web", "Note interne", "Notes publiques", "URL Rencontre", "Salle jitsi", "Nom complet", "9h15", "9h50", "10h25", "11h00", "11h35", "MIDI LUNCH", "13h00", "13h35", "14h10", "14h45", "15h20", "15h55", "16h30"]
    coaches_body_row_1 = ["1", "FALSE", "TestUser", "NumberThree", "Coach", "A - RH, Opérations, stratégie", "Lumas INC", "Direction générale, RH et acquisition talents", "testuser3@gmail.com", "1514-990-1234", "https://www.linkedin.com/in/test3-3798401/", "", "9h00, 9h45, 10h20, 13h00, 13h30, 15h20, 15h55, 16h30", "Gestion humaine simplifiée", "https://collabmachine.com/fr/meet/blitz-test3", "/meet/blitz-test3", "TestUser Three", "", "", "TestUser Three::test3@gmail.com", "x", "x", "x", "TestUser Three::testuser3@gmail.com", "TestUser Three::testuser3@gmail.com", "x", "x", "TestUser Three::testuser3@gmail.com"]
    coaches_body_row_2 = ["2", "TRUE", "TestUser", "NumberFour", "Coach", "A - RH, Opérations, stratégie", "Au delà des possibles", "Modèle d'affaires, coach direction générale", "testuser4@gmail.com", "1514702-8227", "https://www.linkedin.com/in/test4/", "", "Après-midi", "J'accompagne les entrepreneurs passionnés de l'idée au premiers clients", "https://collabmachine.com/fr/meet/blitz-test4", "/meet/blitz-Test4", "TestUser Four", "x", "x", "x", "x", "x", "x", "TestUser Four::testuser4@gmail.com", "TestUser Four::testuser4@gmail.com", "", "TestUser Four::testuser4@gmail", "TestUser Four::testuser4@gmail.com", "TestUser Four::testuser4@gmail.com"]

    expect_any_instance_of(Google::Apis::SheetsV4::SheetsService).to receive(:get_spreadsheet_values).with(
      sheet_id,
      "Participants!A1:AF1"
    ).and_return(
      Google::Apis::SheetsV4::ValueRange.new(
        major_dimension: "ROWS",
        range: "Participants!A1:AF1",
        values: [participants_header_row]
      )
    )
    expect_any_instance_of(Google::Apis::SheetsV4::SheetsService).to receive(:get_spreadsheet_values).with(
      sheet_id,
      "Participants!A2:AF"
    ).and_return(
      Google::Apis::SheetsV4::ValueRange.new(
        major_dimension: "ROWS",
        range: "Participants!A2:AF3",
        values: [participants_body_row_1, participants_body_row_2]
      )
    )
    expect_any_instance_of(Google::Apis::SheetsV4::SheetsService).to receive(:get_spreadsheet_values).with(
      sheet_id,
      "Rencontres Coachs!A1:AE1"
    ).and_return(
      Google::Apis::SheetsV4::ValueRange.new(
        major_dimension: "ROWS",
        range: "'Rencontres Coachs'!A1:AD1",
        values: [coaches_header_row]
      )
    )
    expect_any_instance_of(Google::Apis::SheetsV4::SheetsService).to receive(:get_spreadsheet_values).with(
      sheet_id,
      "Rencontres Coachs!A2:AE"
    ).and_return(
      Google::Apis::SheetsV4::ValueRange.new(
        major_dimension: "ROWS",
        range: "'Rencontres Coachs'!A2:AD3",
        values: [coaches_body_row_1, coaches_body_row_2]
      )
    )
  end
end

RSpec.configure do |config|
  config.include MockHelpers
end
