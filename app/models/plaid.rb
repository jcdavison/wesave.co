class Plaid
  attr_accessor :client_id, :secret, :api_server

  def initialize
    @api_server = 'https://tartan.plaid.com'
    @client_id = PLAID_CLIENT_ID
    @secret = PLAID_SECRET
  end

  def initiate_auth params, user_email
    query = connect_query params[:institution], user_email
    Excon.post("#{@api_server}/connect", query: query)
  end

  def connect_query institution, user_email
    query = { 
      :client_id => client_id,
      :secret => secret,
      :credentials => {
        :username => institution[:username], 
        :password => institution[:password],
        :pin => institution[:pin]
        }, 
      :type => format_type(institution[:type]),
      :email => user_email 
    }
    query[:credentials] = process_credentials query[:credentials]
    set_options_if_bofa query
    query
  end

  def process_credentials  credentials
    credentials.delete :pin if credentials[:pin].empty?
    JSON.generate credentials
  end

  def set_options_if_bofa query
    query[:options] = JSON.generate({list: true}) if query[:type] == 'bofa'
  end

  def format_type institution
    institution_map[institution]
  end

  def institution_map
    { 'American Express' => 'amex',
      'Bank of America' => 'bofa', 
      'Chase' => 'chase', 
      'Citi' => 'citi', 
      'US Bank' => 'us',
      'USAA' => 'usaa',
      'Wells Fargo' => 'wells',
      'Capital One 360' => 'capone360',
      'Charles Schwab' => 'schwab',
      'Fidelity' => 'fidelity' }
  end

  def self.available_institutions
    institution_names.reject do |institution|
      institution.match /chase|citi|us bank/i
    end
  end

  def self.institution_names
    all_institutions.select do |institution|
      institution['products'].include? 'connect'
    end.map {|i| i['name']}
  end

  def self.all_institutions
    JSON.parse(Excon.get(Plaid.new().api_server << "/institutions").body)
  end

  def mfa_step params, institution
    query = mfa_query(params, institution.token)
    ensure_type_set!(query, institution.name)
    Excon.post("#{@api_server}/connect/step", query: query)
  end

  def mfa_query params, token
    { :client_id => client_id,
      :secret => secret,
      :mfa => params[:mfa][:answer],
      :access_token => token }
  end

  def ensure_type_set! query, name
    query[:type] = institution_map[name] if is_sandbox? query
  end

  def is_sandbox? query
    query[:access_token] == 'test'
  end

  def query_object institution
    {access_token: institution.token , client_id: client_id , secret: secret} 
  end

  def self.get_data institution
    plaid = Plaid.new
    query = plaid.query_object institution
    data = JSON.parse(Excon.get("#{plaid.api_server}/connect", query: query ).body)
    plaid.extract data
  end

  def self.destroy_user token 
    plaid = Plaid.new
    query = { access_token: token, secret: plaid.secret, client_id: plaid.client_id }
    JSON.parse(Excon.delete("#{plaid.api_server}/connect", query: query ).body)
  end

  def self.summary account_data
    account_data["accounts"].map do |account|
      { balance: account["balance"]["current"], institution: account["institution_type"], account_name: account["meta"]["name"], account_last4: account["meta"]["number"] }
    end
  end

  def extract data
    {accounts: data['accounts'], 
      transactions: data['transactions']}
  end
end
