🎲🎲 *#{gam.title}* 🎲🎲 Выберите номер и кликните, чтобы участвовать в игре. Это бесплатно. Победитель получит *#{gam.conf('prize')}*. Победитель будет объявлен отдельно.
****
buts ||= []
avlbl_numbers = @tsx_bot.active_game.available_numbers
buts = keyboard(avlbl_numbers, 5) do |rec|
    button("🔸 #{rec}", rec)
end
buts
