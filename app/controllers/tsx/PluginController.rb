module TSX
  module Controllers
    module Plugin

      def save_voting(data)
        Vote.create(
            bot: data.to_i,
            username: hb_client.tele
        )
        update_message "#{icon(@tsx_bot.icon_success)} Спасибо! Ваш голос очень важен, так как он участвует в голосовании за *Лучший Бот Месяца*. Лучший бот будет особо отмечен на странице *Рекомендуем*. Всего в этом месяце проголосовало *#{ludey(Vote::voted_this_month)}*."
      end

      def save_lottery(data)
        Bet.create(
            number: data.to_i,
            client: hb_client.id,
            game: @tsx_bot.active_game.id
        )
        update_message "#{icon(@tsx_bot.icon_success)} Вы выбрали число *#{data}*. Когда рулетка закончится, победитель получит *#{@tsx_bot.amo(@tsx_bot.active_game.conf('amount'))}*"
      end

      def save_question
        Answer.create(
            answer: data.to_s,
            client: hb_client.id,
            game: @tsx_bot.active_game.id
        )
        update_message "#{icon(@tsx_bot.icon_success)} Вы поучаствовали в опросе клиентоа. Ваше мнение для нас важно!*."
      end

      def prize_lottery(game)
        @gam = game
        if @gam.available_numbers.count < 1
          rec = Bet.where(game: @gam.id).limit(1).order(Sequel.lit('RANDOM()')).all
          winner = Client[rec.first.client]
          winner_num = Bet[rec.first.id].number
          @gam.winner = winner.id
          @gam.save
          @tsx_bot.say(winner.tele, "🚨🚨🚨 *Поздравляем!* Выбранный Вами номер *#{winner_num}* выиграл в рулетку! Вы получили *#{@tsx_bot.active_game.conf('prize')}*. Ждем в Аптеке всегда!")
          winner.cashin(@tsx_bot.active_game.conf('amount'), Client::__cash, Meth::__cash, @tsx_bot.beneficiary, "Выигрыш в рулетку. Победа числа *#{winner_num}*.")
          Spam.create(bot: @tsx_bot.id, kind: Spam::BOT_CLIENTS, label: 'Победа числа в лотерею', text: "🚨🚨🚨 Дорогие друзья! Победило число *#{winner_num}*. Клиенту с ником @#{winner.username} пополнен баланс на #{@tsx_bot.active_game.conf('amount')}", status: Spam::NEW)
          puts "DEACTIVATING GAME".colorize(:white_on_red)
          @gam.update(status: Gameplay::GAMEOVER)
          @tsx_bot.active_game.inc
        end
      end

      def play_game
        cur_game = @tsx_bot.active_game
        if cur_game.nil?
          serp
          return
        end
        cur_game.update(last_run: Time.now)
        handle("save_game_res")
        sset("tsx_game", cur_game)
        raise 'Not game instance' if cur_game.nil?
        raise 'Cannot post now' if !cur_game.can_post?(hb_client)
        reply_inline "welcome/#{cur_game.title}", gam: cur_game
        if !cur_game.conf('question')
          unhandle
        end
      rescue
        serp
      end

      def save_game_res(data = nil)
        if callback_query?
          unhandle
          @tsx_bot.active_game.inc
          sget('tsx_game').update(last_run: Time.now)
          send("save_#{sget('tsx_game').title}", data)
        end
        serp
      end

    end
  end
end
