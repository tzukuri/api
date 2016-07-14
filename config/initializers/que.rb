Que.log_formatter = proc do |data|
  if [:job_worked].include?(data[:event])
    JSON.dump(data)
  end
end

