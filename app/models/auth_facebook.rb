class AuthFacebook < ActiveRecord::Base
  belongs_to :user
  
  
  def to_json
    {
      :uid=>self.uid,
      :name=>self.name,
      :email=>self.email
    }
  end
  
  def self.from_omniauth(auth, current_user)
    auth_facebook = where(auth.slice(:uid)).first_or_initialize.tap do |f|
      f.uid = auth.uid
      f.name = auth.info.name
      f.oauth_token = auth.credentials.token
      f.oauth_expires_at = Time.at(auth.credentials.expires_at)
      f.email = auth.info.email
      
      if f.user_id  # has auth fb
        if current_user.try(:hasE3?) and not current_user.try(:hasFB?)
					f.user.merge_child_to_newuser(current_user) # merge to e3 user 
					f.user_id = current_user.id  
				end
      else # new auth fb user 
				if current_user
          f.user_id = current_user.id # binding
        else# 
          user = User.create_from_auth({
            :provider=>"facebook",
            :name=>auth.info.name,
            :email=>"#{Devise.friendly_token[0,8]}@please.change.me",#auth.info.email,
            :password=>Devise.friendly_token[0,20]
          })
          f.user_id = user.id
        end
      end
      f.save!
    end
    return {:auth=>true, :user=>auth_facebook.user} 
  end
  
end
