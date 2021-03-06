defmodule Minitwitter.AccountsTest do
  use Minitwitter.DataCase

  alias Minitwitter.Accounts

  describe "users" do
    alias Minitwitter.Accounts.User

    @valid_attrs %{
      name: "meraj",
      email: "meraj.enigma@gmail.com",
      password: "phoenix",
      password_confirmation: "phoenix"
    }
    # @update_attrs %{}
    @invalid_attrs %{}

    @valid_addresses ~w(user@example.com USER@foo.COM A_US-ER@foo.bar.org
                            first.last@foo.jp alice+bob@baz.cn)
    @invalid_addresses ~w(user@example,com user_at_foo.org user.name@example.
                            foo@bar_baz.com foo@bar+baz.com)

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "does not accept long names" do
      attrs = Map.put(@valid_attrs, :name, String.duplicate("a", 100))
      assert {:error, changeset} = Accounts.create_user(attrs)

      assert %{name: ["should be at most 50 character(s)"]} = errors_on(changeset)
      assert Accounts.list_users() == []
    end

    test "does not accept long emails" do
      attrs = Map.put(@valid_attrs, :email, String.duplicate("abc", 256) <> "@gmail.com")
      assert {:error, changeset} = Accounts.create_user(attrs)

      assert %{email: ["should be at most 255 character(s)"]} = errors_on(changeset)
      assert Accounts.list_users() == []
    end

    test "requires name to be at least 3 chars long" do
      attrs = Map.put(@valid_attrs, :name, "ab")
      {:error, changeset} = Accounts.create_user(attrs)

      assert %{name: ["should be at least 3 character(s)"]} = errors_on(changeset)
      assert Accounts.list_users() == []
    end

    test "email validation should take valid addresses" do
      for valid_address <- @valid_addresses do
        attrs = Map.put(@valid_attrs, :email, valid_address)
        assert {:ok, _changeset} = Accounts.create_user(attrs)
      end
    end

    test "email validation should reject invalid addresses" do
      for invalid_address <- @invalid_addresses do
        attrs = Map.put(@valid_attrs, :email, invalid_address)
        assert {:error, changeset} = Accounts.create_user(attrs)

        assert %{email: ["has invalid format"]} = errors_on(changeset)
        assert Accounts.list_users() == []
      end
    end
  end
end
