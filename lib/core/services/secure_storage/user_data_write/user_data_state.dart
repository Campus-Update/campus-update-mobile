class UserDataState {
  final Map<String, String> data;

  const UserDataState(this.data);

  factory UserDataState.initial() => const UserDataState({});

  UserDataState copyWith(Map<String, String> newData) {
    return UserDataState({...data, ...newData});
  }

  UserDataState remove(String key) {
    final newData = Map<String, String>.from(data)..remove(key);
    return UserDataState(newData);
  }
}