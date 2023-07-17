module FamillesHelper
  def code_postal_fmt(code)
    return code[0, 3] + ' ' + code[3, 3]
  end

  def courriel_desabonne_fmt(val)
    if val
      t 'true'
    else
      t 'false'
    end
  end
end
