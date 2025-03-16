defmodule Cdc.Cldr do
  use Cldr,
    locales: ["en_SG"],
    default_locale: "en_SG",
    providers: [Cldr.Number, Money]
end
