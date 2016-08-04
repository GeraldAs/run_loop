
module RunLoop

  # @!visibility private
  module DeviceAgent

    # @!visibility private
    class Xcodebuild < RunLoop::DeviceAgent::Launcher

      # @!visibility private
      def self.log_file
        path = File.join(Xcodebuild.dot_dir, "xcodebuild.log")
        FileUtils.touch(path) if !File.exist?(path)
        path
      end

      # @!visibility private
      def to_s
        "#<Xcodebuild #{workspace}>"
      end

      # @!visibility private
      def inspect
        to_s
      end

      # @!visibility private
      def name
        :xcodebuild
      end

      # @!visibility private
      def launch
        workspace

        if device.simulator?
          # quits the simulator
          sim = CoreSimulator.new(device, "")
          sim.launch_simulator
        end

        start = Time.now
        RunLoop.log_debug("Waiting for CBX-Runner to build...")
        pid = xcodebuild
        RunLoop.log_debug("Took #{Time.now - start} seconds to build and launch CBX-Runner")
        pid
      end

      # @!visibility private
      def workspace
        @workspace ||= lambda do
          path = RunLoop::Environment.send(:cbxws)
          if path
            path
          else
            raise "The CBXWS env var is undefined. Are you a maintainer?"
          end
        end.call
      end

      # @!visibility private
      def xcodebuild
        env = {
          "COMMAND_LINE_BUILD" => "1",
          "CLOBBER" => "1"
        }

        if device.physical_device?
          identity = RunLoop::Environment.code_sign_identity
          if !identity
            identity = "iPhone Developer"
          end
          env["CODE_SIGN_IDENTITY"] = identity
        end

        args = [
          "xcrun",
          "xcodebuild",
          "-scheme", "CBXAppStub",
          "-workspace", workspace,
          "-config", "Debug",
          "-destination",
          "id=#{device.udid}",
          "test"
        ]

        log_file = Xcodebuild.log_file

        options = {
          :out => log_file,
          :err => log_file
        }

        command = "#{env.map.each { |k, v| "#{k}=#{v}" }.join(" ")} #{args.join(" ")}"
        RunLoop.log_unix_cmd("#{command} >& #{log_file}")

        pid = Process.spawn(env, *args, options)
        Process.detach(pid)
        pid.to_i
      end
    end
  end
end

