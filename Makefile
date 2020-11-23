my_target1:
	for i in $$(ls); do \
		echo "This is a file: $$i"; \
	done

my_target2:
	$(eval MY_VAR := "this is a local variable")
	echo $(MY_VAR)

my_target3:
	echo "$$TMPDIR"

my_target4:
	@echo "hello world"