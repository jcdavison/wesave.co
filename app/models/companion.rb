class Companion
  def self.populate_transactions user, local = false
    user.primary_account.transactions.each do |t|
      query = {date: t.date, user_id: user.id, amount: t.amount.to_f, item_id: t.item_id}
      Excon.post server(local), query: query
    end
  end

  def self.server local
    (local ? 'http://localhost:5000/' : 'http://wesave-companion.herokuapp.com/') << 'transactions'
  end
end
