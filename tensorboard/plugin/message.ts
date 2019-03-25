/* Copyright 2019 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/


export enum HttpMethodType {
  GET = 'GET',
  POST = 'POST',
}

export class RequestOptions {
  public methodType: HttpMethodType;

  /** The content-type request header to use. Cannot be set for a GET request.*/
  public contentType?: string;

  /** The request body to use. This is the object that is passed to the
   * XMLHttpRequest.send() method. If not given the 'send' method is called
   * without an argument.
   */
  public body?: any;

  /** If specified, this will be the value set in the
   * XMLHttpRequest.withCredentials property.
   */
  public withCredentials?: boolean;

  // Validates this object. Throws InvalidRequestOptionsError on error.
  public validate() {
    if (this.methodType === HttpMethodType.GET) {
      // We don't allow a body for a GET.
      if (this.body) {
        throw new Error(
          'body must be missing for a GET request.');
      }
    }
    // We allow body-less or contentType-less POSTs even if they don't
    // make much sense.
  }
}

export enum MessageType {
  REQUEST,
  RESPONSE,
};

interface Message {
  type: MessageType,
  id: number,
}

export interface RequestMessage extends Message {
  url: string,
  options: RequestOptions,
}

export interface ResponseMessage extends Message {
  response: Object,
  error: string | null,
}

