class Gameplay < Sequel::Model(:game)
  include TSX::Helpers

  ACTIVE = 1
  INACTIVE = 0
  GAMEOVER = 3

  JOB = 0
  VIEW = 1

  @progress = 0
  @maximum = 0

  def start
    self.title
  end

  def can_post?(client)
    case self.title
      when 'lottery'
        if client.has_bet?(self)
          false
        elsif self.available_numbers.count <= 1
          false
        else
          true
        end
      when 'voting'
        client.has_vote? ? false : true
      when 'referals'
        return true
      when 'announcement'
        return true
      when 'question'
        client.has_answer?(self) ? true : false
    end
  end

  def available_numbers
    rng = eval("#{self.conf('range')}")
    Bet.where(game: self.id).each do |num|
      [rng] - [num.number]
    end
    rng
  end

  def readable_status
    case self.status
      when Gameplay::ACTIVE
        "активен"
      when Gameplay::INACTIVE
        "неактивен"
      when Gameplay::GAMEOVER
        "завершена"
    end
  end

  def inc
    cur = self.conf('counter')
    self.sconf('counter', (cur.to_i + 1).to_s)
  end

  def conf(key)
    params = JSON.parse(self.config)
    params[key] || 0
  end

  def sconf(key, value)
    params = JSON.parse(self.config)
    params[key] = value
    self.config = JSON.dump(params)
    self.save
  end

end