# Some helper methods so that we can remove a task preloaded by another .rake file.
Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

def remove_task(task_name)
  Rake.application.remove_task(task_name)
end

# For loading specific states:
# Either yield a nil if no states were specified, or yield each state individually.
def with_states

  unless ENV['LOAD_STATES']
    yield nil
    return
  end

  ENV['LOAD_STATES'].split(',').each do |state_abbrev|
    if state = State.find_by_abbrev(state_abbrev.strip.upcase)
      yield state
    else
      puts "Could not find state #{state_abbrev}; skipping."
    end
  end
end

# Reload a given class file.
def class_refresh(*class_names)
  class_names.each do |klass_name|
    Object.class_eval do
      remove_const(klass_name) if const_defined?(klass_name)
    end
    load klass_name.tableize.singularize + ".rb"
  end
end

