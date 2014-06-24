 module SocialLogin
  require 'net/http'
  private
  def self.get_social_user params
    if params[:provider] == 'facebook'
      user = get_user_from_facebook params[:token]
    elsif params[:provider] == 'google_oauth2'
      user = get_user_from_google_oauth2 params[:token]
    else
      user = {error: "Unauthorized"}
    end
    user
  end

  def self.get_user_from_google_oauth2 token
    url = URI.parse("https://www.googleapis.com/oauth2/v2/userinfo")
    req = Net::HTTP::Get.new(url.path)
    req["Authorization"] = "Bearer " +token
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http|http.request(req)}
    if response.code == "200"
      user = JSON.parse(response.body)
      {name: user["name"], email: user["email"], provider: "google_oauth2", uuid: user["id"]}
    else
      {error: "Unauthorized"}
    end
  end

  def self.get_user_from_facebook token
    begin
      user = FbGraph::User.me(token).fetch
      {name: user.name, email: user.email, provider: "facebook", uuid: user.identifier}
    rescue => e
      {error: "Unauthorized"}
    end
  end
end