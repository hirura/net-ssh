unless ENV['NET_SSH_NO_ED25519']

  require 'common'
  require 'net/ssh/authentication/ed25519_loader'
  require 'base64'

  module Authentication

    class TestED25519 < NetSSHTest
      def setup
        raise "No ED25519 set NET_SSH_NO_ED25519 to ignore this test" unless Net::SSH::Authentication::ED25519Loader::LOADED
      end

      def test_openssl_no_pwd_key
        pub = Net::SSH::Buffer.new(Base64.decode64(openssl_public_key_no_pwd.split(' ')[1]))
        _type = pub.read_string
        pub_data = pub.read_string
        priv = openssl_private_key_no_pwd

        pub_key = Net::SSH::Authentication::ED25519::PubKey.new(pub_data)
        priv_key = Net::SSH::Authentication::ED25519::PrivKey.new(priv,nil)

        shared_secret = "Hello"
        signed = priv_key.ssh_do_sign(shared_secret)
        self.assert_equal(true,pub_key.ssh_do_verify(signed,shared_secret))
        self.assert_equal(priv_key.public_key.fingerprint, pub_key.fingerprint)
        self.assert_equal(pub_key.fingerprint, openssl_key_fingerprint_md5_no_pwd)
        self.assert_equal(pub_key.fingerprint('sha256'), openssl_key_fingerprint_sha256_no_pwd)
      end

      def test_openssh_no_pwd_key
        pub = Net::SSH::Buffer.new(Base64.decode64(openssh_public_key_no_pwd.split(' ')[1]))
        _type = pub.read_string
        pub_data = pub.read_string
        priv = openssh_private_key_no_pwd

        pub_key = Net::SSH::Authentication::ED25519::PubKey.new(pub_data)
        priv_key = Net::SSH::Authentication::ED25519::PrivKey.new(priv,nil)

        shared_secret = "Hello"
        signed = priv_key.ssh_do_sign(shared_secret)
        self.assert_equal(true,pub_key.ssh_do_verify(signed,shared_secret))
        self.assert_equal(priv_key.public_key.fingerprint, pub_key.fingerprint)
        self.assert_equal(pub_key.fingerprint, openssh_key_fingerprint_md5_no_pwd)
        self.assert_equal(pub_key.fingerprint('sha256'), openssh_key_fingerprint_sha256_no_pwd)
      end

      def test_openssh_pwd_key
        if defined?(JRUBY_VERSION)
          puts "Skipping password protected ED25519 for JRuby"
          return
        end
        pub = Net::SSH::Buffer.new(Base64.decode64(openssh_public_key_pwd.split(' ')[1]))
        _type = pub.read_string
        pub_data = pub.read_string
        priv = openssh_private_key_pwd

        pub_key = Net::SSH::Authentication::ED25519::PubKey.new(pub_data)
        priv_key = Net::SSH::Authentication::ED25519::PrivKey.new(priv,'pwd')

        shared_secret = "Hello"
        signed = priv_key.ssh_do_sign(shared_secret)
        self.assert_equal(true,pub_key.ssh_do_verify(signed,shared_secret))
        self.assert_equal(priv_key.public_key.fingerprint, pub_key.fingerprint)
        self.assert_equal(pub_key.fingerprint, openssh_key_fingerprint_md5_pwd)
        self.assert_equal(pub_key.fingerprint('sha256'), openssh_key_fingerprint_sha256_pwd)
      end

      def openssl_private_key_no_pwd
        @anonymous_key = <<-EOF
-----BEGIN PRIVATE KEY-----
MC4CAQAwBQYDK2VwBCIEIO8BvFjQCQGGsNbq0c7uh81pvpNhun6uAPTz3lb/cXHA
-----END PRIVATE KEY-----
      EOF
      end

      def openssl_public_key_no_pwd
        'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMTL+4XQBY79kOmizhvTz9HTV5vapBxle1nsDIJdaXB user@host'
      end

      def openssl_key_fingerprint_md5_no_pwd
        "87:24:56:f2:31:cd:b3:dd:a8:fa:a1:88:62:00:50:11"
      end

      def openssl_key_fingerprint_sha256_no_pwd
	'SHA256:3IrK72A3+zeR96UlS/39+ZysrUOwjByMsxSlkVj56ns'
      end

      def openssh_private_key_pwd
        @pwd_key = <<-EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAACmFlczI1Ni1jYmMAAAAGYmNyeXB0AAAAGAAAABBxwCvr3V
/8pWhC/xvTnGJhAAAAEAAAAAEAAAAzAAAAC3NzaC1lZDI1NTE5AAAAICaHkFaGXqYhUVFc
aZ10TPUbkIvmaFXwYRoOS5qE8MciAAAAsNUAhbNQKwNcOr0eNq3nhtjoyeVyH8hRrpWsiY
46vPiECi6R6OdYGSd7W3fdzUDeyOYCY9ZVIjAzENG+9FsygYzMi6XCuw00OuDFLUp4fL4K
i/coUIVqouB4TPQAmsCVXiIRVTWQtRG0kWfFaV3qRt/bc22ZCvCT6ZZ1UmtulqqfUhSlKM
oPcTikV1iWH5Xc+GxRFRRGTN/6HvBf0AKDB1kMXlDhGnBnHGeNH1pk44xG
-----END OPENSSH PRIVATE KEY-----
      EOF
      end

      def openssh_public_key_pwd
        'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICaHkFaGXqYhUVFcaZ10TPUbkIvmaFXwYRoOS5qE8Mci vagrant@vagrant-ubuntu-trusty-64'
      end

      def openssh_key_fingerprint_md5_pwd
        'c8:89:92:60:12:1b:01:5e:ca:58:55:68:7e:5e:1a:f1'
      end

      def openssh_key_fingerprint_sha256_pwd
        'SHA256:Uz5Qk/fB+f8Bu7FTxNcDh7+atpB29Q3tBBJX/gnUfGw'
      end

      def openssh_private_key_no_pwd
        @anonymous_key = <<-EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACAwdjQYeBiTz1DdZFzzLvG+t913L+eVqCgtzpAYxQG8yQAAAKjlHzLo5R8y
6AAAAAtzc2gtZWQyNTUxOQAAACAwdjQYeBiTz1DdZFzzLvG+t913L+eVqCgtzpAYxQG8yQ
AAAEBPrD+n4901Y+NYJ2sry+EWRdltGFhMISvp91TywJ//mTB2NBh4GJPPUN1kXPMu8b63
3Xcv55WoKC3OkBjFAbzJAAAAIHZhZ3JhbnRAdmFncmFudC11YnVudHUtdHJ1c3R5LTY0AQ
IDBAU=
-----END OPENSSH PRIVATE KEY-----
      EOF
      end

      def openssh_public_key_no_pwd
        'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDB2NBh4GJPPUN1kXPMu8b633Xcv55WoKC3OkBjFAbzJ vagrant@vagrant-ubuntu-trusty-64'
      end

      def openssh_key_fingerprint_md5_no_pwd
        '2f:7f:97:21:76:a4:0f:38:c4:fe:d8:b4:6a:39:72:30'
      end

      def openssh_key_fingerprint_sha256_no_pwd
        'SHA256:u6mXnY8P1b0FODGp8mckqOB33u8+jvkSCtJbD5Q9klg'
      end
    end

  end

end
