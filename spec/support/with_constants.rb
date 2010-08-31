def with_constants(constants, &block)
  saved_constants = {}
  constants.each do |constant, val|
    saved_constants[ constant ] = Object.const_get( constant )
    Kernel::silence_warnings { Object.const_set( constant, val ) }
  end
 
  begin
    block.call
  ensure
    constants.each do |constant, val|
      Kernel::silence_warnings { Object.const_set( constant, saved_constants[ constant ] ) }
    end
  end
end