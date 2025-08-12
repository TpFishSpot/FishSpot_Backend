import { Injectable } from '@nestjs/common';

@Injectable()
export class UploadService {
  async uploadImageLocally(file: Express.Multer.File) {
    return {
      imageUrl: `/uploads/${file.filename}`,
      filename: file.filename,
    };
  }
}