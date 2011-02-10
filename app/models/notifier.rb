class Notifier < ActionMailer::Base
  smtp_settings = { :enable_starttls_auto => false }
  delivery_method = :smtp
  
  default from: Status.where(table: 'GLOBAL', name: 'email_from').first.h_display

  def password_reset_instructions(user)
    subject       "Password reset instructions"
    recipients    user.email
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def invitation_to_judge(u, s, i)
    subject       "Invitation to judge"
    from          email_from
    recipients    i.email
    sent_on       Time.now
    headers       'Precedence' => 'bulk'
    body          :user => u, :section => s, :invite => i
  end

  def acceptance_to_judge(u, name, competition)
    subject       u.name + ' has accepted to judge ' + name
    from          email_from
    recipients    competition.user.email
    sent_on       Time.now
    headers       'Precedence' => 'bulk'
    body          :name => name, :u => u
  end

  def refusal_to_judge(email, name, competition)
    subject       email + ' has refused to judge ' + name
    from          email_from
    recipients    competition.user.email
    sent_on       Time.now
    headers       'Precedence' => 'bulk'
    body          :name => name, :email => email
  end
  
  private
  
  def email_from
    Status.where(table: 'GLOBAL', name: 'email_from').first.h_display
  end
end
