# Use the official Ruby image as the base image
FROM ruby:3.0

# Set the working directory to /app
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock com_thetrainline.gemspec ./

# Copy the rest of the application code into the container
COPY . .

# Install gem dependencies
RUN bundle install

# Set the default command to run when the container starts
CMD ["bash"]