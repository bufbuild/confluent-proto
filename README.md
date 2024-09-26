# bufbuild/confluent

[![Build](https://github.com/bufbuild/confluent-proto/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/bufbuild/confluent-proto/actions/workflows/ci.yaml)
[![BSR](https://img.shields.io/badge/BSR-Module-0C65EC)](https://buf.build/bufbuild/confluent)
![License](https://img.shields.io/github/license/bufbuild/confluent-proto)
![GitHub](https://img.shields.io/github/license/bufbuild/confluent-proto)

This module contains Protobuf extensions for integration with the Confluent Schema Registry.

## Usage

Add a dependency on this module in your `buf.yaml`:

```yaml
version: v2
deps:
  # For enterprise users: replace "buf.build" with the hostname of your instance.
  - buf.build/bufbuild/confluent
```

Add this dependency to your `buf.lock`:

```bash
buf dep update
```

To specify the mapping between a given subject and a Protobuf message, set the
`buf.confluent.v1.Subject`. For example, the following defines a mapping between the
`acme.v1.EmailUpdated` message and the Confluent Schema Registry subject `email-updated-value`:

```proto
syntax = "proto3";

package acme.v1;

import "buf/confluent/v1/extensions.proto";

// An event where an email address was updated for a given user.
message EmailUpdated {
  option (buf.confluent.v1.subject) = {
    // The user-specified name for the Confluent Schema Registry instance within the BSR.
    // Instances are managed within BSR admin settings.
    instance_name: "prod"
    // The subject's name as determined by the subject naming strategy.
    //
    // See https://docs.confluent.io/platform/current/schema-registry/fundamentals/serdes-develop/index.html#subject-name-strategy
    // for more details.

    // The default subject name strategy is TopicNameStrategy, which appends either "-key" or
    // "-value" to a Kafka topic's name to create the subject name.
    name: "email-updated-value"
  };

  // The ID of the user associated with this email address update.
  string id = 1;
  // The old email address.
  string old_email_address = 2;
  // The new email address.
  string new_email_address = 3;
}
```

When a Buf module is pushed to the BSR with the Confluent integration enabled, this will
automatically create a subject named `email-updated-value` associated with this message on the
`prod` Confluent Schema Registry instance.
