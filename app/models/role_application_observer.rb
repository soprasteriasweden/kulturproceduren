# Observer for events on role applications
class RoleApplicationObserver < ActiveRecord::Observer

  # Sends a mail to administrators when a new role application
  # has been submitted by a user
  def after_create(role_application)
    RoleApplicationMailer.deliver_application_submitted_email(
      role_application,
      Role.find_by_symbol(:admin).users
    )
  end

  # Sends a mail to the user when an administrator has responded
  # to a role application
  def after_update(role_application)
    RoleApplicationMailer.deliver_application_handled_email(role_application) if role_application.state != RoleApplication::PENDING
  end
end
