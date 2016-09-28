User.delete_all
UserStat.delete_all
UserOption.delete_all
UserProfile.delete_all

User.seed do |u|
  u.id = -1
  u.name = 'system'
  u.username = 'system'
  u.username_lower = 'system'
  u.email = 'no_email'
  u.password = SecureRandom.hex
  u.active = true
  u.admin = true
  u.moderator = true
  u.approved = true
  u.trust_level = TrustLevel[4]
end

UserOption.where(user_id: -1).update_all(
  email_private_messages: false,
  email_direct: false
)

Group.user_trust_level_change!(-1, TrustLevel[4])

