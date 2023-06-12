class UserRules
  include Wongi::Engine
  include Wongi::Engine::DSL

  def iterate(user)
    engine = Wongi::Engine.create

    user.attributes.each do |attr_name, attr_value|
      engine << [user.email, attr_name, attr_value]
    end

    engine.each(user.email, :_, :_) do |elem|
      puts "#{user.email} #{elem.predicate} is #{elem.object}"
    end
  end

  def can_activate_account(user)
    engine = Wongi::Engine.create

    user.attributes.each do |attr_name, attr_value|
      engine << [user.email, attr_name.parameterize.underscore.to_sym, attr_value]
    end

    engine.rule "activable" do
      forall {
        has :A, :active, false
        any {
          option {
            has :A, :rating, true
            greater :rating, 0.3
          }
          option {
            neg :A, :invited_by_id, nil
          }
          option {
            neg :A, :full_name, nil
            neg :A, :description, nil
            neg :A, :avatar, nil
            neg :A, :skill_list, nil
            neg :A, :interest_list, nil
          }
        }
      }
      make {
        action { |token|
          puts format("%s is activable", [token[:A]])
          # can make the user active here !
        }
      }
    end
  end
end
