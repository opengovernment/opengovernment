module OpenGov::StateWise
  def import(options = {})
    State.loadable.each do |state|
      import_state(state, options)
    end
  end
end
