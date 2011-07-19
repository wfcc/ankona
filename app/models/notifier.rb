# coding: utf-8
class Notifier < ActionMailer::Base
  smtp_settings = { :enable_starttls_auto => false }
  delivery_method = :smtp
  
  default Precedence: 'bulk'
  default from: 'dia-x automation <noreply@dia-x.info>'
  default sender: 'dia-x automation <noreply@dia-x.info>'

  #default from: Status.where(table: 'GLOBAL', name: 'email_from').first.h_display

  def password_reset_instructions(user)
    from          email_from
    subject       "Password reset instructions"
    recipients    user.email
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def invitation_to_judge(u, s, i)
    subject       "Invitation to judge"
    @user = u
    @section = s
    @invite = i
    mail to: i.email
  end

  def acceptance_to_judge(u, name, competition)
    subject       u.nick + ' has accepted to be part of ' + name
    @name = name
    @u = u
    mail to:      competition.user.email
  end

  def refusal_to_judge(email, name, competition)
    subject       email + ' has refused to be part of ' + name
    @name = name
    @u = u
    mail to:      competition.user.email
  end
  
  private
  
  def email_from
    Status.where(table: 'GLOBAL', name: 'email_from').first.h_display
  end
end
