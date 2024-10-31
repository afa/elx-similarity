tst:
	mix test
lint:
	mix credo --strict --all
routes:
	mix phx.routes
server:
	mix phx.server
sh:
	iex -S mix
sh-tst:
	MIX_ENV=test iex -S mix
lines:
	env zsh -c 'ls **/*.(ex|exs)'|grep -v '^deps'|grep -v '^_build'|xargs cat|wc -l
