FROM elixir:1.18.3-otp-27-alpine

# Set the environment to production
ENV MIX_ENV=prod

# Prepare application directory
# According to the FHS, the “opt/” folder is reserved for the installation of add-on application software packages
# In this context, “add-on” means software that is not part of the system
WORKDIR /opt/task_system

# Install build dependencies
RUN apk add --no-cache build-base

# Install Hex and Rebar
RUN mix do local.hex --force, local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Fetch and compile application dependencies
RUN mix do deps.get, deps.compile

# Copy only the folder containing the exercise logic
# This avoids copying files that are useless for compilation purposes
COPY lib/ lib/

# Compile the application
RUN mix compile

# Start the application
CMD [ "mix", "run", "--no-halt" ]




