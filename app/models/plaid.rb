class Plaid
  attr_accessor :client_id, :secret
  def initialize
    @api_server = 'https://tartan.plaid.com'
    @client_id = PLAID_CLIENT_ID
    @secret = PLAID_SECRET
    @account_email = PLAID_ACCOUNT_EMAIL
  end

  def self.institution_names
    institutions = self.institutions
    institutions.map {|i| i["name"] }
  end

  def self.institutions
    JSON.parse(Excon.get('https://tartan.plaid.com/institutions').body)
  end

  def self.mfa_details
    institutions = self.institutions
    institutions.inject({}) do |hash, element| 
      hash[element["name"]] = element["mfa"]
      hash
    end
  end

  def initiate_authorization params
    Excon.post("#{@api_server}/connect", query: build_query(params))
  end

  def build_query params
    query = { :client_id => client_id,
      :secret => secret,
      :credentials => {
        :username => params["username"], 
        :password => params["password"],
        :pin => params["pin"]
        }, 
      :type => params["type"], :email => @account_email }
    query[:credentials] = JSON.generate(query[:credentials])
    query
  end
end

