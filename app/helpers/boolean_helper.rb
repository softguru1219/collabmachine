module BooleanHelper
  def friendly_bool(bool)
    bool ? t("g.yes") : t("g.no")
  end
end
