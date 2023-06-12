task fix_message_audiences: :environment do
  Message.where("audience = '--- private\n...\n'").update_all(audience: Message.audiences.private)
  Message.where("audience = '--- public\n...\n'").update_all(audience: Message.audiences.public)
  Message.where("audience = '--- admin\n...\n'").update_all(audience: Message.audiences.admin)

  Message.where.not(audience: Message.audience_values).each do |message|
    raise "Error" if Message.audience_values.any? { |member| message.audience.include?(member) }

    message.update_columns(audience: Message.audiences.private)
  end
end
