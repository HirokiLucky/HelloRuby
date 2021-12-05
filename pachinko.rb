score = 0
random = [0,0,0,0,0,0,1,1,1,7]
total = 0

puts "1回１００円のパチンコゲーム"
puts "いくら課金しますか？"

money = gets.to_i
total += money

while true
    if money <  100
        puts "所持金がなくなりました。課金しますか？(y/n)"
        pachiAddict = gets.chomp!
        if pachiAddict == "n"
            puts "終了します"
            break
        elsif pachiAddict == "y"
            puts "いくら課金しますか？"
            addMoney = gets.to_i
            money += addMoney
            total += addMoney
        else
            puts "理解できない命令です"
            next
        end
    end


    puts "スロットを回しますか？(y/n)"
    input = gets.chomp!
    if input == "n"
        puts "終了します"
        total -= money
        break
    elsif input == "y"
        money -= 100
    else
        puts "理解できない命令です"
        next
    end
        
    a = random.sample
    b = random.sample
    c = random.sample
    puts "#{a}, #{b}, #{c}"

    if a == b && b == c
        case a
        when 0 then
            score += 50
            puts "0のゾロ目、50点獲得"
        when 1 then
            score += 100
            puts "1のゾロ目、１００点獲得"
        when 7 then
            score += 100000
            puts "ジャックポット！100000点獲得！"
        end
    end

    puts "現在のscoreは#{score}点です"
    puts "現在の所持金は#{money}円です"
end

puts "今回のscoreは#{score}点でした"
puts "今回の使ったお金は#{total}円でした"
