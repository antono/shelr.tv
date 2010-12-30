def FileUtils.mkdir_p(foo)
	puts foo
end
