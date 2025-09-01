export interface AuthenticatedUser {
  uid: string;
  email: string;
  roles: string[];
}

export interface RequestWithUser extends Request {
  user: AuthenticatedUser;
}
